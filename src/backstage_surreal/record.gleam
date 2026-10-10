import gleam/list
import gleam/option.{type Option, None, Some}
import offstage/dynamic/serialize
import offstage/dynamic/spec
import offstage/openapi/openapi_type.{type OpenAPIType}
import suweal/identifier.{type Identifier}
import suweal/record

// ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– //
//                                   Export from surreal/record                                  //
// ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– //

/// Redefined from surreal/record
pub type Record(a) =
  record.Record(a)

/// Redefined from surreal/record
pub const create_record = record.Record

/// Redefined from surreal/record
pub const create_id = record.Id

/// Redefined from surreal/record
pub const to_json = record.to_json

/// Redefined from surreal/record
pub const to_surql = record.to_surql

/// Redefined from surreal/record
pub const decoder = record.decoder

/// Redefined from surreal/record
pub const typed_decoder = record.typed_decoder

// ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– //
//                                        Extra Functions                                        //
// ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– //

/// The OpenAPI specification for the `Record` type.
fn openapi_spec(type_: Option(String)) -> OpenAPIType {
  // TODO: Change to one_of with the actual record structure
  openapi_type.string()
  |> openapi_type.format("identifier")
  |> openapi_type.pattern("^(?:[A-Za-z0-9_]{1,20}:)?[A-Za-z0-9]{1,20}$")
  |> openapi_type.example(
    type_
    |> option.or(Some("example"))
    |> identifier.generate
    |> identifier.to_string
    |> spec.string,
  )
}

pub fn serializer(
  serializer: serialize.Serializer(a),
  id: fn(a) -> Identifier(a),
) -> serialize.Serializer(Record(a)) {
  serialize.Serializer(
    decoder: record.decoder(serializer.decoder, id),
    encoder: fn(record) {
      case record {
        record.Id(id) -> spec.string(identifier.to_string(id))
        record.Record(_, value) -> serializer.encoder(value)
      }
    },
    doc: fn() { openapi_spec(None) },
  )
}

pub fn typed_serializer(
  serializer: serialize.Serializer(a),
  id: fn(a) -> Identifier(a),
  types: List(String),
) -> serialize.Serializer(Record(a)) {
  serialize.Serializer(
    decoder: record.typed_decoder(serializer.decoder, id, types),
    encoder: fn(record) {
      case record {
        record.Id(id) -> {
          case types {
            [first, ..] -> identifier.typed(id, first)
            _ -> id
          }
          |> identifier.to_string
          |> spec.string()
        }
        record.Record(_, value) -> serializer.encoder(value)
      }
    },
    doc: fn() { list.first(types) |> option.from_result |> openapi_spec() },
  )
}
