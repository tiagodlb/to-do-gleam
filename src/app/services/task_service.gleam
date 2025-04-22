import app/web.{type Context}
import app/models/task.{type Task}
import app/repositories/task_repository
import gleam/json
import gleam/dynamic/decode
import wisp.{type Request, type Response}

fn task_to_json(task: Task) -> json.Json {
  json.object([
    #("id", json.string(task.id)),
    #("title", json.string(task.title)),
    #("description", json.string(task.description)),
    #("status", json.string(task.status)),
  ])
}

fn task_decoder() -> decode.Decoder(#(String, String, String)) {
  decode.field("title", decode.string, fn(title) {
    decode.field("description", decode.string, fn(description) {
      decode.field("status", decode.string, fn(status) {
        decode.success(#(title, description, status))
      })
    })
  })
}

/// Get all tasks
pub fn list_tasks(ctx: Context) -> Response {
  case task_repository.new(ctx.db) {
    Ok(repository) -> {
      case task_repository.list_all(repository) {
        Ok(tasks) -> {
          json.object([
            #("tasks", json.array(tasks, task_to_json))
          ])
          |> json.to_string_tree
          |> wisp.json_response(200)
        }
        Error(_) -> {
          web.error_response("Failed to retrieve tasks from database")
        }
      }
    }
    Error(_) -> {
      web.error_response("Failed to initialize task repository")
    }
  }
}

/// Create a new task
pub fn create_task(req: Request, ctx: Context) -> Response {
  case task_repository.new(ctx.db) {
    Ok(repository) -> {
      use json_data <- wisp.require_json(req)
      
      case decode.run(json_data, task_decoder()) {
        Ok(#(title, description, status)) -> {
          case task_repository.create(repository, title, description, status) {
            Ok(task) -> {
              json.object([
                #("task", task_to_json(task))
              ])
              |> json.to_string_tree
              |> wisp.json_response(201)
            }
            Error(_) -> {
              web.error_response("Failed to create task in database")
            }
          }
        }
        Error(_) -> {
          json.object([
            #("error", json.string("Invalid JSON format or missing required fields"))
          ])
          |> json.to_string_tree
          |> wisp.json_response(400)
        }
      }
    }
    Error(_) -> {
      web.error_response("Failed to initialize task repository")
    }
  }
}

/// Get a task by ID
pub fn get_task_by_id(ctx: Context, id: String) -> Response {
  case task_repository.new(ctx.db) {
    Ok(repository) -> {
      case task_repository.get_by_id(repository, id) {
        Ok(task) -> {
          json.object([
            #("task", task_to_json(task))
          ])
          |> json.to_string_tree
          |> wisp.json_response(200)
        }
        Error(_) -> {
          json.object([
            #("error", json.string("Task not found"))
          ])
          |> json.to_string_tree
          |> wisp.json_response(404)
        }
      }
    }
    Error(_) -> {
      web.error_response("Failed to initialize task repository")
    }
  }
}

/// Update a task by ID
pub fn update_task(req: Request, ctx: Context, id: String) -> Response {
  case task_repository.new(ctx.db) {
    Ok(repository) -> {
      use json_data <- wisp.require_json(req)
      
      case decode.run(json_data, task_decoder()) {
        Ok(#(title, description, status)) -> {
          case task_repository.update(repository, id, title, description, status) {
            Ok(task) -> {
              json.object([
                #("task", task_to_json(task))
              ])
              |> json.to_string_tree
              |> wisp.json_response(200)
            }
            Error(_) -> {
              json.object([
                #("error", json.string("Task not found or could not be updated"))
              ])
              |> json.to_string_tree
              |> wisp.json_response(404)
            }
          }
        }
        Error(_) -> {
          json.object([
            #("error", json.string("Invalid JSON format or missing required fields"))
          ])
          |> json.to_string_tree
          |> wisp.json_response(400)
        }
      }
    }
    Error(_) -> {
      web.error_response("Failed to initialize task repository")
    }
  }
}

/// Delete a task by ID
pub fn delete_task(_req: Request, ctx: Context, id: String) -> Response {
  case task_repository.new(ctx.db) {
    Ok(repository) -> {
      case task_repository.delete(repository, id) {
        Ok(_) -> {
          wisp.no_content()
        }
        Error(_) -> {
          json.object([
            #("error", json.string("Task not found"))
          ])
          |> json.to_string_tree
          |> wisp.json_response(404)
        }
      }
    }
    Error(_) -> {
      web.error_response("Failed to initialize task repository")
    }
  }
}