import offstage/dynamic/serialize
import suweal/table_spec

/// The table specification using backstage's decoder
pub type TableSpec(a) =
  table_spec.TableSpec(a, serialize.Serializer(a))
