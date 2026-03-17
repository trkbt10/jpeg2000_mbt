#!/usr/bin/env python3

from __future__ import annotations

import argparse
import concurrent.futures
import dataclasses
import os
import re
import shlex
import subprocess
import sys
import tempfile
from datetime import date
from pathlib import Path


@dataclasses.dataclass(frozen=True)
class DumpInfo:
    line: str
    layout: str
    width: int
    height: int
    comps: int
    bits: int
    signed: bool
    sample_hex: str


@dataclasses.dataclass(frozen=True)
class DumpComponentInfo:
    index: int
    width: int
    height: int
    bits: int
    signed: bool
    layout: str
    sample_hex: str


@dataclasses.dataclass(frozen=True)
class AllComponentsDumpInfo:
    line: str
    layout: str
    comps: int
    components: list[DumpComponentInfo]


@dataclasses.dataclass(frozen=True)
class CompareRow:
    fixture: str
    category: str
    reason: str
    repro_command: str

    def as_tsv(self) -> str:
        return "\t".join(
            [self.fixture, self.category, self.reason, self.repro_command]
        )


@dataclasses.dataclass(frozen=True)
class MismatchPoint:
    x: int
    y: int
    decoder: int
    reference: int
    diff: int


@dataclasses.dataclass(frozen=True)
class MismatchSummary:
    mismatch: int
    sample_count: int
    max_abs_diff: int
    first_points: list[MismatchPoint]


@dataclasses.dataclass(frozen=True)
class CompareFixtureResult:
    fixture: str
    path: Path
    row: CompareRow
    dump: DumpInfo | None = None
    all_dump: AllComponentsDumpInfo | None = None
    reference_hex: str | None = None
    reference_component_hexes: list[str] | None = None
    mismatch: MismatchSummary | None = None
    mismatch_component_index: int | None = None


@dataclasses.dataclass(frozen=True)
class PgxCompareInfo:
    width: int
    height: int
    decoder_hex: str


PGX_HEADER_RE = re.compile(
    rb"PG\s+(M[LS])\s+([+-])\s+(\d+)\s+(\d+)\s+(\d+)\s", re.S
)
KNOWN_COMMANDS = {
    "collect",
    "fixture",
    "mismatch-report",
    "diff",
    "priority",
    "render",
}


def main(argv: list[str]) -> int:
    parser = build_parser()
    args = parser.parse_args(normalize_argv(argv))
    args.func(args)
    return 0


def normalize_argv(argv: list[str]) -> list[str]:
    if not argv:
        return ["collect"]
    if argv[0] in {"-h", "--help"}:
        return argv
    if argv[0] in KNOWN_COMMANDS:
        return argv
    return ["collect", *argv]


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Shared tooling for reference implementation fixture comparison. "
            "If no subcommand is given, collect mode is used."
        )
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    collect = subparsers.add_parser(
        "collect", help="compare a corpus or fixture subset and write TSV"
    )
    add_common_compare_args(collect)
    collect.add_argument(
        "--out",
        type=Path,
        help="output TSV path (default: reference/decode_samples_reference_compare_latest.tsv)",
    )
    collect.add_argument(
        "--jobs",
        type=int,
        default=max(1, min(4, os.cpu_count() or 1)),
        help="number of fixture workers (default: min(4, cpu_count))",
    )
    collect.set_defaults(func=command_collect)

    fixture = subparsers.add_parser(
        "fixture", help="show mismatch details for one or more fixtures"
    )
    add_common_compare_args(
        fixture,
        default_from_tsv=True,
        default_category="fail_mismatch",
    )
    fixture.set_defaults(func=command_fixture)

    render = subparsers.add_parser(
        "render",
        help=(
            "materialize current reference implementation expected vs MoonBit actual outputs "
            "(component0 only) into roundtrip/"
        ),
    )
    add_common_compare_args(render)
    render.add_argument(
        "--out-dir",
        type=Path,
        help="output directory (default: <root>/roundtrip/reference-compare-latest)",
    )
    render.add_argument(
        "--jobs",
        type=int,
        default=max(1, min(4, os.cpu_count() or 1)),
        help="number of fixture workers (default: min(4, cpu_count))",
    )
    render.set_defaults(func=command_render)

    mismatch_report = subparsers.add_parser(
        "mismatch-report", help="write first16 mismatch markdown for fail_mismatch fixtures"
    )
    add_common_compare_args(
        mismatch_report,
        include_category=False,
        include_fixtures=False,
    )
    mismatch_report.add_argument(
        "--compare-tsv",
        type=Path,
        help="input TSV path (default: reference/decode_samples_reference_compare_latest.tsv)",
    )
    mismatch_report.add_argument(
        "--out",
        type=Path,
        help="output markdown path (default: reference/decode_samples_mismatch_diffs.md)",
    )
    mismatch_report.add_argument(
        "--jobs",
        type=int,
        default=max(1, min(4, os.cpu_count() or 1)),
        help="number of fixture workers (default: min(4, cpu_count))",
    )
    mismatch_report.set_defaults(func=command_mismatch_report)

    diff = subparsers.add_parser("diff", help="diff two compare TSV files")
    diff.add_argument("before", type=Path, help="baseline TSV")
    diff.add_argument("after", type=Path, help="new TSV")
    diff.add_argument(
        "--out",
        type=Path,
        help="output markdown path (default: reference/decode_samples_reference_compare_delta.md)",
    )
    diff.set_defaults(func=command_diff)

    priority = subparsers.add_parser(
        "priority", help="list priority fail_mismatch fixtures"
    )
    priority.add_argument(
        "--root",
        type=Path,
        default=default_root_dir(),
        help="repository root",
    )
    priority.add_argument(
        "--compare-tsv",
        type=Path,
        help="input TSV path (default: reference/decode_samples_reference_compare_latest.tsv)",
    )
    priority.add_argument(
        "--reference-dump",
        type=Path,
        default=Path(os.environ.get("REFERENCE_DUMP", "/opt/homebrew/bin/opj_dump")),
        help="path to opj_dump",
    )
    priority.add_argument(
        "--bits",
        type=int,
        default=8,
        help="required bits-per-sample for priority output (default: 8)",
    )
    priority.set_defaults(func=command_priority)
    return parser


def add_common_compare_args(
    parser: argparse.ArgumentParser,
    *,
    include_category: bool = True,
    include_fixtures: bool = True,
    default_from_tsv: bool = False,
    default_category: str | None = None,
) -> None:
    parser.add_argument(
        "--root",
        type=Path,
        default=default_root_dir(),
        help="repository root",
    )
    parser.add_argument(
        "--corpus-dir",
        type=Path,
        help="fixture corpus root (default: <root>/samples/corpus)",
    )
    parser.add_argument(
        "--include-htj2k",
        action="store_true",
        help="include files under */htj2k/* when scanning a corpus directory",
    )
    parser.add_argument(
        "--reference-bin",
        type=Path,
        default=Path(os.environ.get("REFERENCE_BIN", "/opt/homebrew/bin/opj_decompress")),
        help="path to opj_decompress",
    )
    parser.add_argument(
        "--all-components",
        action="store_true",
        help="compare all decoded components instead of the current component0-only contract",
    )
    if include_category:
        parser.add_argument(
            "--from-tsv",
            type=Path,
            help="load fixtures from an existing compare TSV",
        )
        parser.add_argument(
            "--category",
            default=default_category,
            help=(
                "when no fixtures are given, read fixture names from --from-tsv "
                f"(default category: {default_category or 'disabled'})"
            ),
        )
        parser.set_defaults(default_from_tsv=default_from_tsv)
    if include_fixtures:
        parser.add_argument("fixtures", nargs="*", help="fixture paths or corpus-relative names")


def default_root_dir() -> Path:
    return Path(__file__).resolve().parents[1]


def default_compare_tsv_path(root_dir: Path, *, all_components: bool) -> Path:
    if all_components:
        return root_dir / "reference/decode_samples_reference_compare_all_components_latest.tsv"
    return root_dir / "reference/decode_samples_reference_compare_latest.tsv"


def default_mismatch_report_path(root_dir: Path, *, all_components: bool) -> Path:
    if all_components:
        return root_dir / "reference/decode_samples_all_components_mismatch_diffs.md"
    return root_dir / "reference/decode_samples_mismatch_diffs.md"


def command_collect(args: argparse.Namespace) -> None:
    root_dir = args.root.resolve()
    corpus_dir = resolve_corpus_dir(root_dir, args.corpus_dir)
    out_path = (
        args.out.resolve()
        if args.out is not None
        else default_compare_tsv_path(root_dir, all_components=args.all_components)
    )
    results = run_fixture_batch(
        build_fixture_specs(
            root_dir,
            corpus_dir,
            getattr(args, "fixtures", []),
            from_tsv=args.from_tsv,
            category=args.category,
            default_from_tsv=args.default_from_tsv,
            all_components=args.all_components,
            include_htj2k=args.include_htj2k,
        ),
        reference_bin=args.reference_bin.resolve(),
        jobs=args.jobs,
        all_components=args.all_components,
        show_progress=True,
    )
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8") as handle:
        handle.write("fixture\tcategory\treason\trepro_command\n")
        for result in results:
            handle.write(result.row.as_tsv())
            handle.write("\n")

    summary = summarize_rows(results)
    print()
    summary_label = (
        "decode_samples(all-components) vs reference implementation summary:"
        if args.all_components
        else "decode_samples vs reference implementation summary:"
    )
    print(summary_label)
    print(f"  total                     : {summary['total']}")
    print(f"  pass_real_match           : {summary['pass_real_match']}")
    print(f"  fail_mismatch             : {summary['fail_mismatch']}")
    print(f"  skip_htj2k_not_supported  : {summary['skip_htj2k_not_supported']}")
    print(f"  skip_zero_recon           : {summary['skip_zero_recon']}")
    print(
        f"  skip_unsupported_precision: {summary['skip_unsupported_precision']}"
    )
    print(f"  hard_fail                 : {summary['hard_fail']}")
    print(f"  details_tsv               : {out_path}")


def command_fixture(args: argparse.Namespace) -> None:
    root_dir = args.root.resolve()
    corpus_dir = resolve_corpus_dir(root_dir, args.corpus_dir)
    results = run_fixture_batch(
        build_fixture_specs(
            root_dir,
            corpus_dir,
            args.fixtures,
            from_tsv=args.from_tsv,
            category=args.category,
            default_from_tsv=args.default_from_tsv,
            all_components=args.all_components,
            include_htj2k=args.include_htj2k,
        ),
        reference_bin=args.reference_bin.resolve(),
        jobs=1,
        all_components=args.all_components,
        need_details=True,
    )
    for result in results:
        if result.row.category not in {"pass_real_match", "fail_mismatch"}:
            print(f"[{result.fixture}] {result.row.category}: {result.row.reason}")
            continue
        if result.mismatch is None:
            print(f"[{result.fixture}] {result.row.category}: {result.row.reason}")
            continue
        mismatch = result.mismatch
        component_label = ""
        if args.all_components and result.mismatch_component_index is not None:
            component_label = f" component={result.mismatch_component_index}"
        pct = (
            mismatch.mismatch * 100.0 / mismatch.sample_count
            if mismatch.sample_count > 0
            else 0.0
        )
        print(
            f"[{result.fixture}]{component_label} mismatch={mismatch.mismatch}/{mismatch.sample_count} "
            f"({pct:.2f}%) max_abs_diff={mismatch.max_abs_diff}"
        )
        if mismatch.first_points:
            detail = ", ".join(
                [
                    "x={x} y={y} dec={decoder} ref={reference} diff={diff:+d}".format(
                        x=point.x,
                        y=point.y,
                        decoder=point.decoder,
                        reference=point.reference,
                        diff=point.diff,
                    )
                    for point in mismatch.first_points
                ]
            )
            print(f"  first: {detail}")


def command_render(args: argparse.Namespace) -> None:
    root_dir = args.root.resolve()
    corpus_dir = resolve_corpus_dir(root_dir, args.corpus_dir)
    out_dir = (
        args.out_dir.resolve()
        if args.out_dir is not None
        else root_dir / "roundtrip/reference-compare-latest"
    )
    results = run_fixture_batch(
        build_fixture_specs(
            root_dir,
            corpus_dir,
            args.fixtures,
            from_tsv=args.from_tsv,
            category=args.category,
            default_from_tsv=args.default_from_tsv,
            all_components=args.all_components,
            include_htj2k=args.include_htj2k,
        ),
        reference_bin=args.reference_bin.resolve(),
        jobs=args.jobs,
        all_components=args.all_components,
        need_details=True,
        show_progress=True,
    )

    out_dir.mkdir(parents=True, exist_ok=True)
    summary_lines = [
        "# Reference Implementation Compare Render",
        "",
        f"Generated: {timestamp_today()}",
        "",
        (
            "Each pair is rendered as component0 only, even when compare mode is all-components."
            if args.all_components
            else "Each pair is component0 only."
        ),
        "",
        "| fixture | category | rendered | moonbit | reference | note |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    rendered_count = 0
    skipped_count = 0

    for result in results:
        moonbit_file = "-"
        reference_file = "-"
        note = result.row.reason
        rendered = "no"

        component0_dump = result.dump
        component0_reference_hex = result.reference_hex
        if args.all_components and result.all_dump is not None:
          if result.all_dump.components:
            component0 = result.all_dump.components[0]
            component0_dump = DumpInfo(
                line=result.all_dump.line,
                layout=component0.layout,
                width=component0.width,
                height=component0.height,
                comps=result.all_dump.comps,
                bits=component0.bits,
                signed=component0.signed,
                sample_hex=component0.sample_hex,
            )
          if result.reference_component_hexes:
            component0_reference_hex = result.reference_component_hexes[0]

        if (
            component0_dump is not None
            and component0_reference_hex is not None
            and result.row.category in {"pass_real_match", "fail_mismatch"}
        ):
            stem = result.path.stem
            moonbit_path = out_dir / f"{stem}_moonbit_component0.pgm"
            reference_path = out_dir / f"{stem}_reference_component0.pgm"
            try:
                write_component0_pgm(
                    component0_dump.sample_hex,
                    width=component0_dump.width,
                    height=component0_dump.height,
                    bits=component0_dump.bits,
                    signed=component0_dump.signed,
                    out_path=moonbit_path,
                )
                write_component0_pgm(
                    component0_reference_hex,
                    width=component0_dump.width,
                    height=component0_dump.height,
                    bits=component0_dump.bits,
                    signed=component0_dump.signed,
                    out_path=reference_path,
                )
                moonbit_file = moonbit_path.name
                reference_file = reference_path.name
                note = "component0_pgm"
                rendered = "yes"
                rendered_count += 1
            except Exception as exc:  # noqa: BLE001
                note = sanitize_reason(str(exc))
                skipped_count += 1
        else:
            skipped_count += 1

        summary_lines.append(
            f"| `{result.fixture}` | {result.row.category} | {rendered} | "
            f"`{moonbit_file}` | `{reference_file}` | {note} |"
        )

    summary_lines.extend(
        [
            "",
            "## Totals",
            "",
            f"- fixtures: {len(results)}",
            f"- rendered: {rendered_count}",
            f"- skipped: {skipped_count}",
        ]
    )
    summary_path = out_dir / "SUMMARY.md"
    summary_path.write_text("\n".join(summary_lines) + "\n", encoding="utf-8")
    print()
    print(f"rendered fixtures : {rendered_count}")
    print(f"skipped fixtures  : {skipped_count}")
    print(f"output dir        : {out_dir}")
    print(f"summary           : {summary_path}")


def command_mismatch_report(args: argparse.Namespace) -> None:
    root_dir = args.root.resolve()
    corpus_dir = resolve_corpus_dir(root_dir, args.corpus_dir)
    compare_tsv = (
        args.compare_tsv.resolve()
        if args.compare_tsv is not None
        else default_compare_tsv_path(root_dir, all_components=args.all_components)
    )
    out_path = (
        args.out.resolve()
        if args.out is not None
        else default_mismatch_report_path(root_dir, all_components=args.all_components)
    )
    fixture_specs = build_fixture_specs(
        root_dir,
        corpus_dir,
        [],
        from_tsv=compare_tsv,
        category="fail_mismatch",
        default_from_tsv=True,
        all_components=args.all_components,
        include_htj2k=args.include_htj2k,
    )
    results = run_fixture_batch(
        fixture_specs,
        reference_bin=args.reference_bin.resolve(),
        jobs=args.jobs,
        all_components=args.all_components,
        need_details=True,
    )
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8") as handle:
        title = (
            "# decode_samples all-components reference implementation mismatch first16 diffs\n\n"
            if args.all_components
            else "# decode_samples reference implementation mismatch first16 diffs\n\n"
        )
        handle.write(title)
        handle.write(f"Updated: {timestamp_today()}\n\n")
        handle.write(
            "| Fixture | component | bits | signed | guard | decoder_samples | reference_samples | "
            "decoder_first16 | reference_first16 | diff(decoder-reference)_first16 |\n"
        )
        handle.write("|---|---:|---:|---|---|---:|---:|---|---|---|\n")
        for result in results:
            if args.all_components:
                if (
                    result.all_dump is None
                    or result.reference_component_hexes is None
                    or result.mismatch_component_index is None
                ):
                    handle.write(
                        f"| {result.fixture} | ? | ? | ? | parse-error | parse-error | "
                        "parse-error | parse-error | parse-error | parse-error |\n"
                    )
                    continue
                component = result.all_dump.components[result.mismatch_component_index]
                reference_hex = result.reference_component_hexes[result.mismatch_component_index]
                decoder_first = first_values_csv(
                    component.sample_hex, component.bits, component.signed, 16
                )
                reference_first = first_values_csv(
                    reference_hex, component.bits, component.signed, 16
                )
                diff_first = diff_csv(decoder_first, reference_first)
                decoder_samples = sample_count_from_hex(component.sample_hex, component.bits)
                reference_samples = sample_count_from_hex(reference_hex, component.bits)
                guard = (
                    "short_samples"
                    if decoder_samples < 16 or reference_samples < 16
                    else "ok"
                )
                handle.write(
                    f"| {result.fixture} | {component.index} | {component.bits} | "
                    f"{str(component.signed).lower()} | {guard} | "
                    f"{decoder_samples} | {reference_samples} | "
                    f"`{decoder_first}` | `{reference_first}` | `{diff_first}` |\n"
                )
                continue

            if result.dump is None or result.reference_hex is None:
                handle.write(
                    f"| {result.fixture} | ? | ? | ? | parse-error | parse-error | "
                    "parse-error | parse-error | parse-error | parse-error |\n"
                )
                continue
            decoder_first = first_values_csv(
                result.dump.sample_hex, result.dump.bits, result.dump.signed, 16
            )
            reference_first = first_values_csv(
                result.reference_hex, result.dump.bits, result.dump.signed, 16
            )
            diff_first = diff_csv(decoder_first, reference_first)
            decoder_samples = sample_count_from_hex(result.dump.sample_hex, result.dump.bits)
            reference_samples = sample_count_from_hex(result.reference_hex, result.dump.bits)
            guard = (
                "short_samples"
                if decoder_samples < 16 or reference_samples < 16
                else "ok"
            )
            handle.write(
                f"| {result.fixture} | 0 | {result.dump.bits} | "
                f"{str(result.dump.signed).lower()} | {guard} | "
                f"{decoder_samples} | {reference_samples} | "
                f"`{decoder_first}` | `{reference_first}` | `{diff_first}` |\n"
            )
    print(f"wrote: {out_path}")


def command_diff(args: argparse.Namespace) -> None:
    before_path = args.before.resolve()
    after_path = args.after.resolve()
    require_file(before_path, "before tsv")
    require_file(after_path, "after tsv")
    out_path = (
        args.out.resolve()
        if args.out is not None
        else default_root_dir() / "reference/decode_samples_reference_compare_delta.md"
    )

    before_rows = read_compare_rows(before_path)
    after_rows = read_compare_rows(after_path)
    categories = [
        "pass_real_match",
        "fail_mismatch",
        "skip_zero_recon",
        "skip_unsupported_precision",
        "hard_fail",
    ]
    fixtures = sorted(set(before_rows) | set(after_rows))

    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8") as handle:
        handle.write("# Reference Implementation Compare TSV Delta\n\n")
        handle.write("| Metric | Before | After | Delta |\n")
        handle.write("|---|---:|---:|---:|\n")
        for category in categories:
            before_count = count_category(before_rows, category)
            after_count = count_category(after_rows, category)
            handle.write(
                f"| {category} | {before_count} | {after_count} | "
                f"{after_count - before_count} |\n"
            )
        handle.write("\n## Fixture Category Changes\n\n")
        handle.write("| Fixture | Before | After |\n")
        handle.write("|---|---|---|\n")
        for fixture in fixtures:
            before_category = before_rows.get(fixture, "-")
            after_category = after_rows.get(fixture, "-")
            if before_category != after_category:
                handle.write(
                    f"| {fixture} | {before_category} | {after_category} |\n"
                )
    print(f"wrote: {out_path}")


def command_priority(args: argparse.Namespace) -> None:
    root_dir = args.root.resolve()
    compare_tsv = (
        args.compare_tsv.resolve()
        if args.compare_tsv is not None
        else root_dir / "reference/decode_samples_reference_compare_latest.tsv"
    )
    require_file(compare_tsv, "compare tsv")
    reference_dump = args.reference_dump.resolve()
    if not reference_dump.is_file() or not os.access(reference_dump, os.X_OK):
        raise SystemExit(f"error: opj_dump not found: {reference_dump}")

    print(f"priority mismatch fixtures ({args.bits}bit + single-tile):")
    for fixture in read_fixtures_from_tsv(compare_tsv, "fail_mismatch"):
        path = root_dir / "samples/corpus" / fixture
        if not path.is_file():
            continue
        dump = parse_dump_info(
            run_command(
                ["moon", "run", "cmd/main", "--", "decode-file-dump", str(path)],
                allow_failure=True,
            )
        )
        if dump is None or dump.bits != args.bits:
            continue
        tw, th = parse_tile_grid(
            run_command([str(reference_dump), "-i", str(path)], allow_failure=True)
        )
        if tw == 1 and th == 1:
            print(fixture)


def timestamp_today() -> str:
    return date.today().isoformat()


def require_file(path: Path, label: str) -> None:
    if not path.is_file():
        raise SystemExit(f"error: {label} not found: {path}")


def resolve_corpus_dir(root_dir: Path, corpus_dir: Path | None) -> Path:
    target = corpus_dir.resolve() if corpus_dir is not None else root_dir / "samples/corpus"
    if not target.is_dir():
        raise SystemExit(f"error: corpus directory not found: {target}")
    return target


def build_fixture_specs(
    root_dir: Path,
    corpus_dir: Path,
    fixtures: list[str],
    *,
    from_tsv: Path | None,
    category: str | None,
    default_from_tsv: bool,
    all_components: bool = False,
    include_htj2k: bool = False,
) -> list[tuple[str, Path]]:
    if fixtures:
        specs = [resolve_fixture_spec(root_dir, corpus_dir, fixture) for fixture in fixtures]
    elif category is not None or default_from_tsv:
        tsv_path = (
            from_tsv.resolve()
            if from_tsv is not None
            else default_compare_tsv_path(root_dir, all_components=all_components)
        )
        specs = [
            resolve_fixture_spec(root_dir, corpus_dir, fixture)
            for fixture in read_fixtures_from_tsv(
                tsv_path, category or "fail_mismatch"
            )
        ]
    else:
        specs = list_all_corpus_fixture_specs(corpus_dir, include_htj2k=include_htj2k)
    if not specs:
        raise SystemExit("error: no fixtures selected")
    return dedupe_fixture_specs(specs)


def dedupe_fixture_specs(specs: list[tuple[str, Path]]) -> list[tuple[str, Path]]:
    seen: set[Path] = set()
    deduped: list[tuple[str, Path]] = []
    for fixture, path in specs:
        resolved = path.resolve()
        if resolved in seen:
            continue
        seen.add(resolved)
        deduped.append((fixture, resolved))
    return deduped


def read_fixtures_from_tsv(tsv_path: Path, category: str) -> list[str]:
    require_file(tsv_path, "compare tsv")
    fixtures: list[str] = []
    with tsv_path.open("r", encoding="utf-8") as handle:
        for line in handle:
            fixture, row_category, *_rest = line.rstrip("\n").split("\t")
            if fixture == "fixture":
                continue
            if row_category == category:
                fixtures.append(fixture)
    return fixtures


def list_all_corpus_fixture_specs(
    corpus_dir: Path, *, include_htj2k: bool = False
) -> list[tuple[str, Path]]:
    paths = list(corpus_dir.rglob("*.j2k")) + list(corpus_dir.rglob("*.j2c"))
    if include_htj2k:
        paths += list(corpus_dir.rglob("*.jph")) + list(corpus_dir.rglob("*.jhc"))
    paths = sorted(paths, key=lambda path: str(path.relative_to(corpus_dir)))
    if not include_htj2k:
        paths = [
            path
            for path in paths
            if "htj2k" not in {part.lower() for part in path.relative_to(corpus_dir).parts}
        ]
    return [(path.name, path.resolve()) for path in paths]


def resolve_fixture_spec(
    root_dir: Path, corpus_dir: Path, fixture: str
) -> tuple[str, Path]:
    candidate = Path(fixture)
    possible = []
    if candidate.is_absolute():
        possible.append(candidate)
    else:
        possible.extend([candidate, root_dir / candidate, corpus_dir / candidate])
    for path in possible:
        if path.is_file():
            return path.name, path.resolve()
    raise SystemExit(f"error: fixture not found: {fixture}")


def read_compare_rows(tsv_path: Path) -> dict[str, str]:
    rows: dict[str, str] = {}
    with tsv_path.open("r", encoding="utf-8") as handle:
        for line in handle:
            fixture, category, *_rest = line.rstrip("\n").split("\t")
            if fixture == "fixture":
                continue
            rows[fixture] = category
    return rows


def count_category(rows: dict[str, str], category: str) -> int:
    return sum(1 for row_category in rows.values() if row_category == category)


def parse_tile_grid(output: str) -> tuple[int | None, int | None]:
    match = re.search(r"tw=(\d+), th=(\d+)", output)
    if match is None:
        return None, None
    return int(match.group(1)), int(match.group(2))


def run_fixture_batch(
    specs: list[tuple[str, Path]],
    *,
    reference_bin: Path,
    jobs: int,
    all_components: bool = False,
    need_details: bool = False,
    show_progress: bool = False,
) -> list[CompareFixtureResult]:
    if not reference_bin.is_file() or not os.access(reference_bin, os.X_OK):
        raise SystemExit(f"error: opj_decompress not found: {reference_bin}")

    results: list[CompareFixtureResult] = []
    if jobs <= 1:
        for spec in specs:
            result = compare_fixture(
                spec,
                reference_bin=reference_bin,
                all_components=all_components,
                need_details=need_details,
            )
            results.append(result)
            if show_progress:
                print_progress(result)
        return sort_results(results)

    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as executor:
        future_map = {
            executor.submit(
                compare_fixture,
                spec,
                reference_bin=reference_bin,
                all_components=all_components,
                need_details=need_details,
            ): spec
            for spec in specs
        }
        for future in concurrent.futures.as_completed(future_map):
            result = future.result()
            results.append(result)
            if show_progress:
                print_progress(result)
    return sort_results(results)


def sort_results(results: list[CompareFixtureResult]) -> list[CompareFixtureResult]:
    return sorted(results, key=lambda result: result.fixture)


def print_progress(result: CompareFixtureResult) -> None:
    print(f"[{result.fixture}] {result.row.category} | {result.row.reason}")


def compare_fixture(
    spec: tuple[str, Path],
    *,
    reference_bin: Path,
    all_components: bool,
    need_details: bool,
) -> CompareFixtureResult:
    if all_components:
        return compare_fixture_all_components(
            spec,
            reference_bin=reference_bin,
            need_details=need_details,
        )
    return compare_fixture_component0(
        spec,
        reference_bin=reference_bin,
        need_details=need_details,
    )


def compare_fixture_component0(
    spec: tuple[str, Path], *, reference_bin: Path, need_details: bool
) -> CompareFixtureResult:
    fixture, path = spec
    dump_out = run_command(
        ["moon", "run", "cmd/main", "--", "decode-file-dump", str(path)],
        allow_failure=True,
    )
    dump = parse_dump_info(dump_out)
    repro_decode = shlex.join(
        ["moon", "run", "cmd/main", "--", "decode-file-dump", str(path)]
    )
    if dump is None:
        reason = sanitize_reason(dump_out or "decode-file-dump failed")
        category = (
            "skip_htj2k_not_supported"
            if "DS-UNSUPPORTED-HTJ2K" in reason
            else "hard_fail"
        )
        row = CompareRow(
            fixture=fixture,
            category=category,
            reason=reason,
            repro_command=repro_decode,
        )
        return CompareFixtureResult(fixture=fixture, path=path, row=row)

    if ":zero_recon:" in dump.layout:
        row = CompareRow(
            fixture=fixture,
            category="skip_zero_recon",
            reason=dump.layout,
            repro_command=repro_decode,
        )
        return CompareFixtureResult(fixture=fixture, path=path, row=row, dump=dump)

    if dump.bits <= 0 or dump.bits > 31:
        row = CompareRow(
            fixture=fixture,
            category="skip_unsupported_precision",
            reason=f"unsupported target precision bits={dump.bits}",
            repro_command=repro_decode,
        )
        return CompareFixtureResult(fixture=fixture, path=path, row=row, dump=dump)

    repro_out_dir = Path("/tmp/j2k_out_compare")
    repro_out_dir.mkdir(parents=True, exist_ok=True)
    repro_reference = shlex.join(
        [
            str(reference_bin),
            "-quiet",
            "-i",
            str(path),
            "-o",
            str(repro_out_dir / f"{path.stem}.pgx"),
        ]
    )
    repro_compare = f"{repro_decode} && {repro_reference}"

    try:
        with tempfile.TemporaryDirectory(prefix="reference-compare-") as temp_dir:
            temp_path = Path(temp_dir)
            pgx_base = temp_path / f"{path.stem}.pgx"
            decode = subprocess.run(
                [str(reference_bin), "-quiet", "-i", str(path), "-o", str(pgx_base)],
                check=False,
                capture_output=True,
                text=True,
            )
            if decode.returncode != 0:
                row = CompareRow(
                    fixture=fixture,
                    category="hard_fail",
                    reason="reference implementation decode failed",
                    repro_command=repro_compare,
                )
                return CompareFixtureResult(
                    fixture=fixture, path=path, row=row, dump=dump
                )

            pgx_path = temp_path / f"{path.stem}_0.pgx"
            if not pgx_path.is_file():
                pgx_path = pgx_base
            if not pgx_path.is_file():
                row = CompareRow(
                    fixture=fixture,
                    category="hard_fail",
                    reason="reference implementation pgx component0 not found",
                    repro_command=repro_compare,
                )
                return CompareFixtureResult(
                    fixture=fixture, path=path, row=row, dump=dump
                )

            reference_hex = pgx_to_decoder_hex(
                pgx_path, target_bits=dump.bits, target_signed=dump.signed
            )
    except Exception as exc:  # noqa: BLE001
        row = CompareRow(
            fixture=fixture,
            category="hard_fail",
            reason=sanitize_reason(str(exc)),
            repro_command=repro_compare,
        )
        return CompareFixtureResult(fixture=fixture, path=path, row=row, dump=dump)

    category = "pass_real_match" if dump.sample_hex == reference_hex else "fail_mismatch"
    row = CompareRow(
        fixture=fixture,
        category=category,
        reason=(
            "byte_match_reference"
            if category == "pass_real_match"
            else "byte_mismatch_reference"
        ),
        repro_command=repro_compare,
    )
    mismatch = (
        mismatch_summary(
            width=dump.width,
            bits=dump.bits,
            signed=dump.signed,
            decoder_hex=dump.sample_hex,
            reference_hex=reference_hex,
        )
        if need_details
        else None
    )
    return CompareFixtureResult(
        fixture=fixture,
        path=path,
        row=row,
        dump=dump,
        reference_hex=reference_hex if need_details else None,
        mismatch=mismatch,
    )


def collect_reference_component_paths(
    temp_path: Path, stem: str, component_count: int
) -> list[Path] | None:
    paths: list[Path] = []
    pgx_base = temp_path / f"{stem}.pgx"
    for index in range(component_count):
        candidate = temp_path / f"{stem}_{index}.pgx"
        if candidate.is_file():
            paths.append(candidate)
            continue
        if index == 0 and component_count == 1 and pgx_base.is_file():
            paths.append(pgx_base)
            continue
        return None
    return paths


def compare_fixture_all_components(
    spec: tuple[str, Path], *, reference_bin: Path, need_details: bool
) -> CompareFixtureResult:
    fixture, path = spec
    dump_out = run_command(
        ["moon", "run", "cmd/main", "--", "decode-file-all-components-dump", str(path)],
        allow_failure=True,
    )
    dump = parse_all_components_dump_info(dump_out)
    repro_decode = shlex.join(
        ["moon", "run", "cmd/main", "--", "decode-file-all-components-dump", str(path)]
    )
    if dump is None:
        reason = sanitize_reason(dump_out or "decode-file-all-components-dump failed")
        category = (
            "skip_htj2k_not_supported"
            if "DS-UNSUPPORTED-HTJ2K" in reason
            else "hard_fail"
        )
        row = CompareRow(
            fixture=fixture,
            category=category,
            reason=reason,
            repro_command=repro_decode,
        )
        return CompareFixtureResult(fixture=fixture, path=path, row=row)

    if ":zero_recon:" in dump.layout or any(
        ":zero_recon:" in component.layout for component in dump.components
    ):
        row = CompareRow(
            fixture=fixture,
            category="skip_zero_recon",
            reason=dump.layout,
            repro_command=repro_decode,
        )
        return CompareFixtureResult(
            fixture=fixture,
            path=path,
            row=row,
            all_dump=dump,
        )

    for component in dump.components:
        if component.bits <= 0 or component.bits > 31:
            row = CompareRow(
                fixture=fixture,
                category="skip_unsupported_precision",
                reason=f"unsupported target precision bits={component.bits} component={component.index}",
                repro_command=repro_decode,
            )
            return CompareFixtureResult(
                fixture=fixture,
                path=path,
                row=row,
                all_dump=dump,
            )

    repro_out_dir = Path("/tmp/j2k_out_compare")
    repro_out_dir.mkdir(parents=True, exist_ok=True)
    repro_reference = shlex.join(
        [
            str(reference_bin),
            "-quiet",
            "-i",
            str(path),
            "-o",
            str(repro_out_dir / f"{path.stem}.pgx"),
        ]
    )
    repro_compare = f"{repro_decode} && {repro_reference}"

    try:
        with tempfile.TemporaryDirectory(prefix="reference-compare-") as temp_dir:
            temp_path = Path(temp_dir)
            pgx_base = temp_path / f"{path.stem}.pgx"
            decode = subprocess.run(
                [str(reference_bin), "-quiet", "-i", str(path), "-o", str(pgx_base)],
                check=False,
                capture_output=True,
                text=True,
            )
            if decode.returncode != 0:
                row = CompareRow(
                    fixture=fixture,
                    category="hard_fail",
                    reason="reference implementation decode failed",
                    repro_command=repro_compare,
                )
                return CompareFixtureResult(
                    fixture=fixture,
                    path=path,
                    row=row,
                    all_dump=dump,
                )

            component_paths = collect_reference_component_paths(
                temp_path,
                path.stem,
                dump.comps,
            )
            if component_paths is None:
                row = CompareRow(
                    fixture=fixture,
                    category="hard_fail",
                    reason="reference implementation pgx component set not found",
                    repro_command=repro_compare,
                )
                return CompareFixtureResult(
                    fixture=fixture,
                    path=path,
                    row=row,
                    all_dump=dump,
                )

            reference_hexes: list[str] = []
            mismatch_index: int | None = None
            mismatch_details: MismatchSummary | None = None
            reason = "byte_match_reference_all_components"

            for component, pgx_path in zip(dump.components, component_paths):
                pgx_info = read_pgx_compare_info(
                    pgx_path,
                    target_bits=component.bits,
                    target_signed=component.signed,
                )
                reference_hexes.append(pgx_info.decoder_hex)
                if pgx_info.width != component.width or pgx_info.height != component.height:
                    reason = (
                        "dimension_mismatch_reference_all_components:"
                        f"component={component.index}:"
                        f"decoder={component.width}x{component.height}:"
                        f"reference={pgx_info.width}x{pgx_info.height}"
                    )
                    mismatch_index = component.index
                    break
                if component.sample_hex != pgx_info.decoder_hex:
                    reason = f"byte_mismatch_reference_all_components:component={component.index}"
                    mismatch_index = component.index
                    if need_details:
                        mismatch_details = mismatch_summary(
                            width=component.width,
                            bits=component.bits,
                            signed=component.signed,
                            decoder_hex=component.sample_hex,
                            reference_hex=pgx_info.decoder_hex,
                        )
                    break
            category = "pass_real_match" if mismatch_index is None else "fail_mismatch"
            row = CompareRow(
                fixture=fixture,
                category=category,
                reason=reason,
                repro_command=repro_compare,
            )
            return CompareFixtureResult(
                fixture=fixture,
                path=path,
                row=row,
                all_dump=dump,
                reference_component_hexes=reference_hexes if need_details else None,
                mismatch=mismatch_details,
                mismatch_component_index=mismatch_index,
            )
    except Exception as exc:  # noqa: BLE001
        row = CompareRow(
            fixture=fixture,
            category="hard_fail",
            reason=sanitize_reason(str(exc)),
            repro_command=repro_compare,
        )
        return CompareFixtureResult(fixture=fixture, path=path, row=row, all_dump=dump)


def parse_dump_info(output: str) -> DumpInfo | None:
    line = next(
        (entry.strip() for entry in output.splitlines() if entry.startswith("ok-dump:")),
        None,
    )
    if line is None:
        return None
    layout = extract_field(line, r" layout=([^ ]+) ")
    width = extract_int_field(line, r" w=([0-9]+) ")
    height = extract_int_field(line, r" h=([0-9]+) ")
    comps = extract_int_field(line, r" comps=([0-9]+) ")
    bits = extract_int_field(line, r" bits=([0-9]+) ")
    signed_raw = extract_field(line, r" signed=([^ ]+) ")
    sample_hex = extract_field(line, r" samples_hex=([0-9a-f]+)$")
    if None in {layout, width, height, comps, bits, signed_raw, sample_hex}:
        return None
    return DumpInfo(
        line=line,
        layout=layout,
        width=width,
        height=height,
        comps=comps,
        bits=bits,
        signed=(signed_raw == "true"),
        sample_hex=sample_hex,
    )


def parse_all_components_dump_info(output: str) -> AllComponentsDumpInfo | None:
    line = next(
        (
            entry.strip()
            for entry in output.splitlines()
            if entry.startswith("ok-dump-all:")
        ),
        None,
    )
    if line is None:
        return None
    layout = extract_field(line, r" layout=([^ ]+)$")
    comps = extract_int_field(line, r" comps=([0-9]+) ")
    if layout is None or comps is None:
        return None
    components: list[DumpComponentInfo] = []
    for entry in output.splitlines():
        if not entry.startswith("ok-dump-component:"):
            continue
        component_line = entry.strip()
        index = extract_int_field(component_line, r" index=([0-9]+) ")
        width = extract_int_field(component_line, r" w=([0-9]+) ")
        height = extract_int_field(component_line, r" h=([0-9]+) ")
        bits = extract_int_field(component_line, r" bits=([0-9]+) ")
        signed_raw = extract_field(component_line, r" signed=([^ ]+) ")
        component_layout = extract_field(component_line, r" layout=([^ ]+) ")
        sample_hex = extract_field(component_line, r" samples_hex=([0-9a-f]+)$")
        if None in {
            index,
            width,
            height,
            bits,
            signed_raw,
            component_layout,
            sample_hex,
        }:
            return None
        components.append(
            DumpComponentInfo(
                index=index,
                width=width,
                height=height,
                bits=bits,
                signed=(signed_raw == "true"),
                layout=component_layout,
                sample_hex=sample_hex,
            )
        )
    components.sort(key=lambda component: component.index)
    if len(components) != comps:
        return None
    return AllComponentsDumpInfo(
        line=line,
        layout=layout,
        comps=comps,
        components=components,
    )


def extract_field(line: str, pattern: str) -> str | None:
    match = re.search(pattern, line)
    return match.group(1) if match else None


def extract_int_field(line: str, pattern: str) -> int | None:
    value = extract_field(line, pattern)
    return int(value) if value is not None else None


def sanitize_reason(text: str) -> str:
    stripped = " ".join(text.replace("\t", " ").split())
    return stripped if stripped else "unknown"


def run_command(argv: list[str], *, allow_failure: bool = False) -> str:
    result = subprocess.run(
        argv,
        check=False,
        capture_output=True,
        text=True,
    )
    output = (result.stdout + result.stderr).replace("\r", "")
    if result.returncode != 0 and not allow_failure:
        raise RuntimeError(output.strip() or f"command failed: {shlex.join(argv)}")
    return output


def read_pgx_compare_info(
    pgx_path: Path, *, target_bits: int, target_signed: bool
) -> PgxCompareInfo:
    data = pgx_path.read_bytes()
    match = PGX_HEADER_RE.match(data)
    if match is None:
        raise ValueError("invalid pgx header")
    endian, sign, prec_bytes, width_bytes, height_bytes = match.groups()
    prec = int(prec_bytes)
    width = int(width_bytes)
    height = int(height_bytes)
    if prec <= 0 or prec > 31:
        raise ValueError("unsupported pgx precision")
    if target_bits <= 0 or target_bits > 31:
        raise ValueError("invalid target bits")
    payload = data[match.end() :]
    src_bytes = 1 if prec <= 8 else 2
    expected = width * height * src_bytes
    if len(payload) < expected:
        raise ValueError("payload short")

    dst_bytes = (target_bits + 7) // 8
    target_mask = (1 << target_bits) - 1
    src_mask = (1 << prec) - 1
    src_sign_bit = 1 << (prec - 1)
    if target_signed:
        target_sign_min = -(1 << (target_bits - 1))
        target_sign_max = (1 << (target_bits - 1)) - 1
        target_storage_mask = (1 << (dst_bytes * 8)) - 1

    out = bytearray()
    for index in range(width * height):
        start = index * src_bytes
        chunk = payload[start : start + src_bytes]
        raw = int.from_bytes(chunk, byteorder="big" if endian == b"ML" else "little")
        raw &= src_mask
        value = raw
        if sign == b"-" and (raw & src_sign_bit) != 0:
            value = raw - (1 << prec)

        if target_signed:
            if value < target_sign_min:
                value = target_sign_min
            if value > target_sign_max:
                value = target_sign_max
            encoded = value & target_storage_mask
        else:
            if value < 0:
                value = 0
            if value > target_mask:
                value = target_mask
            encoded = value & target_mask
        out.extend(encoded.to_bytes(dst_bytes, byteorder="little"))
    return PgxCompareInfo(width=width, height=height, decoder_hex=out.hex())


def pgx_to_decoder_hex(pgx_path: Path, *, target_bits: int, target_signed: bool) -> str:
    return read_pgx_compare_info(
        pgx_path,
        target_bits=target_bits,
        target_signed=target_signed,
    ).decoder_hex


def write_component0_pgm(
    hex_string: str,
    *,
    width: int,
    height: int,
    bits: int,
    signed: bool,
    out_path: Path,
) -> None:
    if bits <= 0 or bits > 16:
        raise ValueError(f"unsupported pgm precision bits={bits}")
    values = decode_sample_values(hex_string, bits, signed)
    if len(values) != width * height:
        raise ValueError(
            f"sample count mismatch: expected {width * height}, got {len(values)}"
        )
    maxval = (1 << bits) - 1
    if signed:
        bias = 1 << (bits - 1)
        encoded_values = [
            max(0, min(maxval, value + bias))
            for value in values
        ]
    else:
        encoded_values = [
            max(0, min(maxval, value))
            for value in values
        ]

    if bits <= 8:
        payload = bytes(encoded_values)
    else:
        payload = b"".join(value.to_bytes(2, byteorder="big") for value in encoded_values)

    header = f"P5\n{width} {height}\n{maxval}\n".encode("ascii")
    out_path.write_bytes(header + payload)


def sample_count_from_hex(hex_string: str, bits: int) -> int:
    sample_bytes = (bits + 7) // 8
    if sample_bytes <= 0:
        return 0
    return (len(hex_string) // 2) // sample_bytes


def decode_sample_values(hex_string: str, bits: int, signed: bool) -> list[int]:
    sample_bytes = (bits + 7) // 8
    if sample_bytes <= 0:
        return []
    data = bytes.fromhex(hex_string)
    mask = (1 << bits) - 1
    sign_bit = 1 << (bits - 1)
    values: list[int] = []
    for offset in range(0, len(data), sample_bytes):
        chunk = data[offset : offset + sample_bytes]
        if len(chunk) < sample_bytes:
            break
        value = int.from_bytes(chunk, byteorder="little") & mask
        if signed and (value & sign_bit) != 0:
            value -= 1 << bits
        values.append(value)
    return values


def mismatch_summary(
    *,
    width: int,
    bits: int,
    signed: bool,
    decoder_hex: str,
    reference_hex: str,
) -> MismatchSummary:
    decoder_values = decode_sample_values(decoder_hex, bits, signed)
    reference_values = decode_sample_values(reference_hex, bits, signed)
    sample_count = min(len(decoder_values), len(reference_values))
    mismatch = 0
    max_abs_diff = 0
    first_points: list[MismatchPoint] = []
    for index in range(sample_count):
        decoder_value = decoder_values[index]
        reference_value = reference_values[index]
        if decoder_value == reference_value:
            continue
        diff = decoder_value - reference_value
        mismatch += 1
        max_abs_diff = max(max_abs_diff, abs(diff))
        if len(first_points) < 8:
            first_points.append(
                MismatchPoint(
                    x=index % width,
                    y=index // width,
                    decoder=decoder_value,
                    reference=reference_value,
                    diff=diff,
                )
            )
    return MismatchSummary(
        mismatch=mismatch,
        sample_count=sample_count,
        max_abs_diff=max_abs_diff,
        first_points=first_points,
    )


def first_values_csv(hex_string: str, bits: int, signed: bool, limit: int) -> str:
    values = decode_sample_values(hex_string, bits, signed)[:limit]
    return ",".join(str(value) for value in values)


def diff_csv(left_csv: str, right_csv: str) -> str:
    left_values = [int(value) for value in left_csv.split(",") if value]
    right_values = [int(value) for value in right_csv.split(",") if value]
    count = min(len(left_values), len(right_values))
    return ",".join(str(left_values[index] - right_values[index]) for index in range(count))


def summarize_rows(results: list[CompareFixtureResult]) -> dict[str, int]:
    summary = {
        "total": len(results),
        "pass_real_match": 0,
        "fail_mismatch": 0,
        "skip_htj2k_not_supported": 0,
        "skip_zero_recon": 0,
        "skip_unsupported_precision": 0,
        "hard_fail": 0,
    }
    for result in results:
        if result.row.category in summary:
            summary[result.row.category] += 1
    return summary


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
