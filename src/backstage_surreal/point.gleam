import dynamic/serialize
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

pub fn serializer() -> serialize.Serializer(Point) {
  serialize.Serializer(
    decoder: point.decoder(),
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
