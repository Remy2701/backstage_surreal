import dynamic/serialize
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

pub fn serializer() -> serialize.Serializer(Identifier(a)) {
  serialize.Serializer(
    decoder: identifier.decoder(),
    encoder: fn(id) { spec.string(identifier.to_string(id)) },
    doc: fn() { openapi_spec(None) },
  )
}

pub fn typed_serializer(
  types: List(String),
) -> serialize.Serializer(Identifier(a)) {
  serialize.Serializer(
    decoder: identifier.typed_decoder(types),
    encoder: fn(id) {
      case types {
        [first, ..] -> identifier.typed(id, first)
        _ -> id
      }
      |> identifier.to_string()
      |> spec.string()
    },
    doc: fn() { list.first(types) |> option.from_result |> openapi_spec() },
  )
}
