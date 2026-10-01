import dynamic/decode
import dynamic/encode
import dynamic/spec
import gleam/list
import gleam/option.{type Option, None, Some}
import openapi/openapi_type.{type OpenAPIType}
import surreal/identifier.{type Identifier}

/// The OpenAPI specification for the `Identifier` type.
fn openapi_spec(type_: Option(String)) -> OpenAPIType {
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

/// The decoder for the `Identifier` type.
pub fn decoder() -> decode.Decoder(Identifier(a)) {
  decode.Decoder(decoder: identifier.decoder(), doc: fn() { openapi_spec(None) })
}

/// The decoder for the `Identifier` type with a specific type prefix.
pub fn typed_decoder(types: List(String)) -> decode.Decoder(Identifier(a)) {
  decode.Decoder(decoder: identifier.typed_decoder(types), doc: fn() {
    list.first(types) |> option.from_result |> openapi_spec()
  })
}

/// The encoder for the `Identifier` type.
pub fn encoder() -> encode.Encoder(Identifier(a)) {
  encode.Encoder(
    encoder: fn(id) { spec.string(identifier.to_string(id)) },
    doc: fn() { openapi_spec(None) },
  )
}

/// The encoder for the `Identifier` type with a specific type prefix.
pub fn typed_encoder(type_: String) -> encode.Encoder(Identifier(a)) {
  encode.Encoder(
    encoder: fn(id) {
      id |> identifier.typed(type_) |> identifier.to_string |> spec.string
    },
    doc: fn() { openapi_spec(Some(type_)) },
  )
}
