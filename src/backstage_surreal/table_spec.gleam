import dynamic/decode
import surreal/table_spec

/// The table specification using backstage's decoder
pub type TableSpec(a) =
  table_spec.TableSpec(a, decode.Decoder(a))
