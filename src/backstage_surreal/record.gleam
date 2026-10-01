import dynamic/decode
import dynamic/encode
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

/// The decoder for the `Record` type.
pub fn decoder(
  decoder: decode.Decoder(a),
  id: fn(a) -> Identifier(a),
) -> decode.Decoder(Record(a)) {
  decode.Decoder(decoder: record.decoder(decoder.decoder, id), doc: fn() {
    openapi_spec(None)
  })
}

/// The encoder for the `Record` type.
pub fn encoder(encoder: encode.Encoder(a)) -> encode.Encoder(Record(a)) {
  encode.Encoder(
    encoder: fn(record) {
      case record {
        record.Id(id) -> spec.string(identifier.to_string(id))
        record.Record(_, value) -> encoder.encoder(value)
      }
    },
    doc: fn() { openapi_spec(None) },
  )
}
