import offstage/dynamic/serialize
import offstage/dynamic/spec
import offstage/openapi/openapi_type.{type OpenAPIType}
import suweal/point

// ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– //
//                                   Export from surreal/point                                   //
// ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– //

/// Redefined from surreal/point
pub type Point =
  point.Point

/// Redefined from surreal/point
pub const create = point.Point

/// Redefined from surreal/point
pub const decoder = point.decoder

/// Redefined from surreal/point
pub const to_json = point.to_json

/// Redefined from surreal/point
pub const to_surql = point.to_surql

// ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– //
//                                        Extra Functions                                        //
// ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– //

/// The OpenAPI specifications for the `Point` type.
fn openapi_spec() -> OpenAPIType {
  openapi_type.object([
    openapi_type.ObjectProperty(
      name: "type",
      type_: openapi_type.string_enum(["Point"]),
      required: True,
    ),
    openapi_type.ObjectProperty(
      name: "coordinates",
      type_: openapi_type.array(
        openapi_type.number() |> openapi_type.format("double"),
      ),
      required: True,
    ),
  ])
}

/// The serializer for Point
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
