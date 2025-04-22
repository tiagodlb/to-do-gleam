import app/services/task_service
import app/web.{type Context}
import gleam/http.{Get, Post, Put, Delete}
import wisp.{type Request, type Response}

/// Handle requests for the tasks collection endpoint
pub fn tasks(req: Request, ctx: Context) -> Response {
  case req.method {
    Get -> list_tasks(ctx)
    Post -> create_task(req, ctx)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

/// Handle requests for individual task endpoints
pub fn task_by_id(req: Request, ctx: Context, id: String) -> Response {
  case req.method {
    Get -> get_task(ctx, id)
    Put -> update_task(req, ctx, id)
    Delete -> delete_task(req, ctx, id)
    _ -> wisp.method_not_allowed([Get, Put, Delete])
  }
}

/// List all tasks
fn list_tasks(ctx: Context) -> Response {
  task_service.list_tasks(ctx)
}

/// Create a new task
fn create_task(req: Request, ctx: Context) -> Response {
  task_service.create_task(req, ctx)
}

/// Get a specific task by ID
fn get_task(ctx: Context, id: String) -> Response {
  task_service.get_task_by_id(ctx, id)
}

/// Update a specific task
fn update_task(req: Request, ctx: Context, id: String) -> Response {
  task_service.update_task(req, ctx, id)
}

/// Delete a specific task
fn delete_task(req: Request, ctx: Context, id: String) -> Response {
  task_service.delete_task(req, ctx, id)
}