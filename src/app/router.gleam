import app/web.{type Context}
import app/controllers/task_controller
import app/controllers/health_controller
import gleam/json
import wisp.{type Response, type Request}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["api", "v1", ..rest] -> handle_v1_routes(req, ctx, rest)
    
    ["health"] -> health_controller.check(req)
    
    ["tasks"] -> task_controller.tasks(req, ctx)
    ["tasks", id] -> task_controller.task_by_id(req, ctx, id)
    
    [] -> {
      json.object([
        #("name", json.string("Todo API")),
        #("version", json.string("1.0.0")),
        #("status", json.string("running")),
        #("documentation", json.string("/api/docs"))
      ])
      |> json.to_string_tree
      |> wisp.json_response(200)
    }
    
    _ -> wisp.not_found()
  }
}

fn handle_v1_routes(req: Request, ctx: Context, path_segments: List(String)) -> Response {
  case path_segments {
    ["tasks"] -> task_controller.tasks(req, ctx)
    ["tasks", id] -> task_controller.task_by_id(req, ctx, id)
        
    _ -> wisp.not_found()
  }
}