import dynamic/decode
import dynamic/encode
import dynamic/spec
import openapi/openapi_type.{type OpenAPIType}
import surreal/point.{type Point}

/// The OpenAPI specifications for the `Point` type.
fn openapi_spec() -> OpenAPIType {
  openapi_type.object([
    #("type", openapi_type.string_enum(["Point"])),
    #(
      "coordinates",
      openapi_type.array(openapi_type.number() |> openapi_type.format("double")),
    ),
  ])
}

/// The decoder for the `Point` type.
pub fn decoder() -> decode.Decoder(Point) {
  decode.Decoder(decoder: point.decoder(), doc: openapi_spec)
}

/// The encoder for the `Point` type.
pub fn encoder() -> encode.Encoder(Point) {
  encode.Encoder(
    encoder: fn(point: Point) {
      spec.object([
        #("type", spec.string("Point")),
        #(
          "coordinates",
          spec.array([
            spec.float(point.latitude),
            spec.float(point.longitude),
          ]),
        ),
      ])
    },
    doc: openapi_spec,
  )
}
