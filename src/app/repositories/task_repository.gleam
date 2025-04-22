import app/cache.{type Cache}
import app/models/task.{type Task, Task}
import gleam/dynamic/decode
import gleam/int
import gleam/io
import gleam/result
import gleam/string
import pog

pub type Repository { 
  Repository(connection: pog.Connection, task_cache: Cache(Task))  
}

pub fn new(connection: pog.Connection) -> Result(Repository, Nil) {
  case cache.new() {
    Ok(task_cache) -> Ok(Repository(connection: connection, task_cache: task_cache))
    Error(_) -> Error(Nil)
  }
}

fn task_decoder() -> decode.Decoder(Task) {
  decode.field(0, decode.int, fn(id) {
    decode.field(1, decode.string, fn(title) {
      decode.field(2, decode.string, fn(description) {
        decode.field(3, decode.string, fn(status) {
          let id_string = int.to_string(id)
          
          decode.success(Task(
            id: id_string, 
            title: title, 
            description: description, 
            status: status
          ))
        })
      })
    })
  })
}

pub fn list_all(repository: Repository) -> Result(List(Task), Nil) {
  let sql_query = "SELECT id, title, description, status FROM tasks ORDER BY id"

  let result = 
    pog.query(sql_query)
    |> pog.returning(task_decoder())
    |> pog.execute(repository.connection)
  
  case result {
    Ok(response) -> Ok(response.rows)
    Error(db_error) -> {
      io.println("Database error fetching tasks:")
      io.println(string.inspect(db_error))
      Error(Nil)
    }
  }
}

pub fn create(
  repository: Repository, 
  title: String, 
  description: String, 
  status: String
) -> Result(Task, Nil) {
  let sql_query = "
    INSERT INTO tasks (title, description, status) 
    VALUES ($1, $2, $3) 
    RETURNING id, title, description, status"

  let result = 
    pog.query(sql_query)
    |> pog.parameter(pog.text(title))
    |> pog.parameter(pog.text(description))
    |> pog.parameter(pog.text(status))
    |> pog.returning(task_decoder())
    |> pog.execute(repository.connection)
  
  case result {
    Ok(response) -> {
      case response.rows {
        [task, ..] -> {
          cache.set(repository.task_cache, task.id, task)
          Ok(task)
        }
        [] -> Error(Nil)
      }
    }
    Error(db_error) -> {
      io.println("Database error creating task:")
      io.println(string.inspect(db_error))
      Error(Nil)
    }
  }
}

pub fn get_by_id(repository: Repository, id: String) -> Result(Task, Nil) {
  case cache.get(repository.task_cache, id) {
    Ok(task) -> Ok(task)
    Error(_) -> {
      let sql_query = "SELECT id, title, description, status FROM tasks WHERE id = $1"

      case int.parse(id) {
        Ok(id_int) -> {
          let result = 
            pog.query(sql_query)
            |> pog.parameter(pog.int(id_int))
            |> pog.returning(task_decoder())
            |> pog.execute(repository.connection)
          
          case result {
            Ok(response) -> {
              case response.rows {
                [task, ..] -> {
                  cache.set(repository.task_cache, task.id, task)
                  Ok(task)
                }
                [] -> Error(Nil)
              }
            }
            Error(db_error) -> {
              io.println("Database error fetching task by ID:")
              io.println(string.inspect(db_error))
              Error(Nil)
            }
          }
        }
        Error(_) -> {
          Error(Nil)
        }
      }
    }
  }
}

pub fn update(
  repository: Repository, 
  id: String, 
  title: String, 
  description: String, 
  status: String
) -> Result(Task, Nil) {
  case int.parse(id) {
    Ok(id_int) -> {
      let sql_query = "
        UPDATE tasks 
        SET title = $2, description = $3, status = $4 
        WHERE id = $1 
        RETURNING id, title, description, status"

      let result = 
        pog.query(sql_query)
        |> pog.parameter(pog.int(id_int))
        |> pog.parameter(pog.text(title))
        |> pog.parameter(pog.text(description))
        |> pog.parameter(pog.text(status))
        |> pog.returning(task_decoder())
        |> pog.execute(repository.connection)
      
      case result {
        Ok(response) -> {
          case response.rows {
            [task, ..] -> {
              cache.set(repository.task_cache, task.id, task)
              Ok(task)
            }
            [] -> Error(Nil)
          }
        }
        Error(db_error) -> {
          io.println("Database error updating task:")
          io.println(string.inspect(db_error))
          Error(Nil)
        }
      }
    }
    Error(_) -> {
      Error(Nil)
    }
  }
}

pub fn delete(repository: Repository, id: String) -> Result(Nil, Nil) {
  case int.parse(id) {
    Ok(id_int) -> {
      let sql_query = "DELETE FROM tasks WHERE id = $1"

      let result = 
        pog.query(sql_query)
        |> pog.parameter(pog.int(id_int))
        |> pog.execute(repository.connection)
      
      case result {
        Ok(response) -> {
          case response.count > 0 {
            True -> {
              let _ = cache.get(repository.task_cache, id)
                |> result.map(fn(_) { 
                  cache.set(repository.task_cache, id, Task(id, "", "", ""))
                })
              
              Ok(Nil)
            }
            False -> Error(Nil)
          }
        }
        Error(db_error) -> {
          io.println("Database error deleting task:")
          io.println(string.inspect(db_error))
          Error(Nil)
        }
      }
    }
    Error(_) -> {
      Error(Nil)
    }
  }
}