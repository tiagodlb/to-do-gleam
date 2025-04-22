import gleam/json
import wisp.{type Request, type Response}

pub fn check(_req: Request) -> Response {
  let health_data = json.object([
    #("status", json.string("ok")),
    #("api", json.string("healthy")),
  ])
  
  health_data
  |> json.to_string_tree
  |> wisp.json_response(200)
}