import backstage
import backstage/backstage_core
import gjwt/key
import gleam/result
import openapi/openapi
import surreal/auth
import surreal/identifier.{type Identifier}

/// A type representing the authentication information of a user.
pub type UserAuth(a) {
  UserAuth(id: Identifier(a))
}

/// Verify the given JWT token using the given key and the type_ to remap it.
fn verify_user_token(
  jwt: String,
  key: key.Key,
  type_: String,
  unauthorized: backstage.UnauthorizedResponse,
) -> Result(Identifier(a), backstage.WispResponse) {
  auth.verify_jwt(jwt, key)
  |> result.try(fn(payload) {
    identifier.from_string(payload.id)
    |> result.map(identifier.typed(_, type_))
  })
  |> result.map_error(fn(_) { unauthorized.apply("Invalid token") })
}

/// Get the identifier of the user from the authorization header and return an error if no token is
/// provided or if the token is invalid. The `key` is used to verify the JWT.
pub fn get_user_token(
  request: backstage.Request,
  type_: String,
  key: key.Key,
  unauthorized: backstage.UnauthorizedResponse,
) -> Result(Identifier(a), backstage.WispResponse) {
  use jwt <- result.try(backstage.require_authorization(request, unauthorized))

  verify_user_token(jwt, key, type_, unauthorized)
}

/// Add user authentication to the route with the name for the security scheme, 
/// the type of the identifier and the JWT key to use.
pub fn user_auth(
  next: backstage.Next(_, next),
  name: String,
  type_: String,
  key: key.Key,
) -> backstage.SequentialNext(UserAuth(a), next) {
  let unauthorized = backstage.unauthorized(next)
  backstage_core.sequential(
    next: next,
    doc: fn(doc) {
      doc
      |> unauthorized.doc()
      |> backstage_core.modify_operation(fn(operation) {
        operation
        |> openapi.operation.security(name)
      })
      |> backstage_core.modify_doc(fn(doc) {
        openapi.components.security_scheme(doc, name, "http", fn(security) {
          security
          |> openapi.security_scheme.scheme("bearer")
          |> openapi.security_scheme.bearer_format("JWT")
        })
      })
    },
    single: fn(request) {
      use unauthorized <- result.try(unauthorized.single(request))
      use id <- result.try(get_user_token(request, type_, key, unauthorized))

      Ok(UserAuth(id: id))
    },
  )
}
