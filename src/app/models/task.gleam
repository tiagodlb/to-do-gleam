pub type Task {
  Task(
    id: String,
    title: String,
    description: String,
    status: String,
  )
}

pub const status_todo = "todo"
pub const status_in_progress = "in_progress"
pub const status_done = "done"

pub fn is_valid_status(status: String) -> Bool {
  status == status_todo || status == status_in_progress || status == status_done
}