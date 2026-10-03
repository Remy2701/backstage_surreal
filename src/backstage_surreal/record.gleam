import dynamic/serialize
import dynamic/spec
import gleam/option.{type Option, None, Some}
import openapi/openapi_type.{type OpenAPIType}
import surreal/identifier.{type Identifier}
import surreal/record.{type Record}

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
