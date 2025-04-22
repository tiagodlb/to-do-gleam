import app/router
import app/web
import gleam/erlang/process
import gleam/option.{Some}
import gleam/int
import gleam/result
import mist
import wisp
import wisp/wisp_mist
import pog
import envoy
import dotenv_gleam

pub fn main() -> Nil {
  let _ = dotenv_gleam.config()
  
  wisp.configure_logger()
  wisp.set_logger_level(wisp.InfoLevel)
  
  let secret_key_base = get_secret_key()
  wisp.log_info("Starting To-do API service...")

  let db_config = 
    pog.default_config()
    |> pog.host(get_env("DB_HOST", ""))
    |> pog.database(get_env("DB_NAME", ""))
    |> pog.user(get_env("DB_USER", ""))
    |> pog.password(Some(get_env("DB_PASSWORD", "")))
    |> pog.port(get_env_int("DB_PORT", 5432))
    |> pog.pool_size(get_env_int("DB_POOL_SIZE", 15))
    |> pog.default_timeout(get_env_int("DB_TIMEOUT", 5000))
  
  wisp.log_info("Connecting to database...")
  let db = pog.connect(db_config)
  wisp.log_info("Connected to database successfully")

  let context = web.Context(db: db)

  let handler = router.handle_request(_, context)
  let server_port = get_env_int("PORT", 8000)

  wisp.log_info("Starting HTTP server on port " <> int.to_string(server_port))
  let result = 
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(server_port)
    |> mist.start_http
  
  case result {
    Ok(_) -> {
      wisp.log_info("Server started successfully on port " <> int.to_string(server_port))
      wisp.log_info("API endpoints:")
      
      // Basic endpoints
      wisp.log_info("  GET    /              - API information")
      wisp.log_info("  GET    /health        - Health check")
      
      // Version 1 API endpoints
      wisp.log_info("  === Version 1 API ===")
      wisp.log_info("  GET    /api/v1/tasks        - List all tasks")
      wisp.log_info("  POST   /api/v1/tasks        - Create a new task")
      wisp.log_info("  GET    /api/v1/tasks/:id    - Get a task by ID")
      wisp.log_info("  PUT    /api/v1/tasks/:id    - Update a task")
      wisp.log_info("  DELETE /api/v1/tasks/:id    - Delete a task")
      
      // Legacy endpoints (for backward compatibility)
      wisp.log_info("  === Legacy API ===")
      wisp.log_info("  GET    /tasks              - List all tasks")
      wisp.log_info("  POST   /tasks              - Create a new task")
      wisp.log_info("  GET    /tasks/:id          - Get a task by ID")
      wisp.log_info("  PUT    /tasks/:id          - Update a task")
      wisp.log_info("  DELETE /tasks/:id          - Delete a task")
      
      process.sleep_forever()
    }
    Error(_) -> {
      wisp.log_error("Failed to start server")
      Nil
    }
  }
}

fn get_env(name: String, default: String) -> String {
  envoy.get(name)
  |> result.unwrap(default)
}

fn get_env_int(name: String, default: Int) -> Int {
  envoy.get(name)
  |> result.then(int.parse)
  |> result.unwrap(default)
}

fn get_secret_key() -> String {
  envoy.get("APP_SECRET")
  |> result.map(fn(secret) {
    case secret {
      "" -> wisp.random_string(64)
      _ -> secret
    }
  })
  |> result.unwrap(wisp.random_string(64))
}