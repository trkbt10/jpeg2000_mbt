///|
// Public type aliases re-exported from focused internal packages.
// Keep the top-level package self-contained for library consumers.

///|
pub type MarkerClass = @core.MarkerClass

///|
pub type MarkerSegment = @core.MarkerSegment

///|
pub type Codestream = @core.Codestream

///|
pub type CodestreamMetadata = @core.CodestreamMetadata

///|
pub type SizComponentMetadata = @core.SizComponentMetadata

///|
pub type SizMetadata = @core.SizMetadata

///|
pub type CodMetadata = @core.CodMetadata

///|
pub type QcdMetadata = @core.QcdMetadata

///|
pub type TileCodMetadata = @core.TileCodMetadata

///|
pub type TileQcdMetadata = @core.TileQcdMetadata

///|
pub type CocMetadata = @core.CocMetadata

///|
pub type RgnMetadata = @core.RgnMetadata

///|
pub type QccMetadata = @core.QccMetadata

///|
pub type PocMetadata = @core.PocMetadata

///|
pub type TlmEntryMetadata = @core.TlmEntryMetadata

///|
pub type TlmMetadata = @core.TlmMetadata

///|
pub type PlmChunkMetadata = @core.PlmChunkMetadata

///|
pub type PlmMetadata = @core.PlmMetadata

///|
pub type PltMetadata = @core.PltMetadata

///|
pub type PpmChunkMetadata = @core.PpmChunkMetadata

///|
pub type PpmMetadata = @core.PpmMetadata

///|
pub type PptMetadata = @core.PptMetadata

///|
pub type SopMetadata = @core.SopMetadata

///|
pub type CrgComponentMetadata = @core.CrgComponentMetadata

///|
pub type CrgMetadata = @core.CrgMetadata

///|
pub type ComMetadata = @core.ComMetadata

///|
pub type ReferenceGridMetadata = @core.ReferenceGridMetadata

///|
pub type ComponentGeometryMetadata = @core.ComponentGeometryMetadata

///|
pub type TileGeometryMetadata = @core.TileGeometryMetadata

///|
pub type TileComponentGeometryMetadata = @core.TileComponentGeometryMetadata

///|
pub type OrderingMetadata = @core.OrderingMetadata

///|
pub type OrderingCodingMetadata = @core.OrderingCodingMetadata

///|
pub type PrecinctResolutionMetadata = @core.PrecinctResolutionMetadata

///|
pub type CodeBlockResolutionMetadata = @core.CodeBlockResolutionMetadata

///|
pub type PacketUnitMetadata = @core.PacketUnitMetadata

///|
pub type ProgressionStepMetadata = @core.ProgressionStepMetadata

///|
pub type ProgressionVolumeMetadata = @core.ProgressionVolumeMetadata

///|
pub type ProgressionMetadata = @core.ProgressionMetadata

///|
pub type PacketHeaderCodeBlockMetadata = @core.PacketHeaderCodeBlockMetadata

///|
pub type PacketHeaderMetadata = @core.PacketHeaderMetadata

///|
pub type TagTreeLevelMetadata = @core.TagTreeLevelMetadata

///|
pub struct DecodeSamplesResult {
  width : Int
  height : Int
  num_components : Int
  bits_per_component : Int
  is_signed : Bool
  sample_layout : String
  samples : Bytes
}
