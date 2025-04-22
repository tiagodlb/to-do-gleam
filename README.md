# Todo API

A RESTful API for task management (fancy name for a to-do) built with Gleam and Wisp.

## Stack

- **[Gleam](https://gleam.run/)**: Language of choice. Safe, fast, and friendly
- **[Wisp](https://github.com/lpil/wisp)**: HTTP framework
- **[pog](https://github.com/lpil/pog)**: PostgreSQL client for Gleam
- **[Envoy](https://github.com/lpil/envoy)**: Environment variables

## Features

- **RESTful API Design**: Standard HTTP methods for resource manipulation
- **Versioned API**: Supports API evolution via `/api/v1/...` routes
- **JSON Handling**: Complete JSON request/response cycle
- **Database Integration**: PostgreSQL backend with connection pooling
- **Environment Configuration**: Configuration via environment variables
- **Health Endpoint**: System health monitoring endpoint
- **Auto-timestamps**: Automatic tracking of creation and update times

## Installation

1. Clone the repository:

```sh
git clone https://github.com/yourusername/todo-api.git
cd todo-api
```

2. Install dependencies:

```sh
gleam deps download
```

3. Create a `.env` file in the project root (see `.env.example`):

```sh
cp .env.example .env
# Edit .env with your configuration
```

4. Set up the database:

```sh
# Create the database
psql -U username -d postgres -c "CREATE DATABASE to_do_database;"

# Apply the schema
psql -U username -d to_do_database -f db_setup.sql
```

5. Build and run the application:

```sh
gleam run
```

## API Endpoints

### Version 1 API

| Method | Endpoint              | Description          | Request Body                                       | Response                            |
|--------|----------------------|----------------------|---------------------------------------------------|-------------------------------------|
| GET    | /api/v1/tasks         | List all tasks       | -                                                 | `{ "tasks": [...] }`                |
| POST   | /api/v1/tasks         | Create a new task    | `{ "title": "", "description": "", "status": "" }` | `{ "task": {...} }`                 |
| GET    | /api/v1/tasks/:id     | Get a task by ID     | -                                                 | `{ "task": {...} }`                 |
| PUT    | /api/v1/tasks/:id     | Update a task        | `{ "title": "", "description": "", "status": "" }` | `{ "task": {...} }`                 |
| DELETE | /api/v1/tasks/:id     | Delete a task        | -                                                 | No content (204)                    |

### System Endpoints

| Method | Endpoint              | Description          | Response                                            |
|--------|----------------------|----------------------|-----------------------------------------------------|
| GET    | /                     | API information      | `{ "name": "Todo API", "version": "1.0.0", ... }`   |
| GET    | /health               | Health check         | `{ "status": "ok", "database": "connected", ... }`  |

### Legacy Endpoints

The API also supports the same endpoints without the `/api/v1` prefix for backward compatibility.

### Task Status Values

Valid status values (enforced by database constraint):
- `todo`
- `in_progress`
- `done`

## Example Requests

### List all tasks

```
GET /api/v1/tasks
```

### Create a task

```
POST /api/v1/tasks
Content-Type: application/json

{
  "title": "Finish README",
  "description": "Complete the project documentation",
  "status": "todo"
}
```

### Get a task by ID

```
GET /api/v1/tasks/1
```

### Update a task

```
PUT /api/v1/tasks/1
Content-Type: application/json

{
  "title": "Finish README",
  "description": "Complete the project documentation",
  "status": "done"
}
```

### Delete a task

```
DELETE /api/v1/tasks/1
```

## Database Schema

The application uses a PostgreSQL database with the following schema:

```sql
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT chk_valid_status CHECK (status IN ('todo', 'in_progress', 'done'))
);
```

- **Auto-incremented ID**: Each task gets a unique identifier
- **Status Validation**: Database constraint ensures only valid status values
- **Timestamps**: Automatic tracking of creation and update times
- **Indexing**: Status field is indexed for faster queries
- **Update Trigger**: Automatically updates the `updated_at` timestamp

## Development

### Project Structure

```
├── src/
│   ├── app/
│   │   ├── controllers/
│   │   │   ├── health_controller.gleam
│   │   │   └── task_controller.gleam
│   │   ├── models/
│   │   │   └── task.gleam
│   │   ├── repositories/
│   │   │   └── task_repository.gleam
│   │   ├── services/
│   │   │   └── task_service.gleam
│   │   ├── router.gleam
│   │   └── web.gleam
│   └── api.gleam
├── .env
├── .env.example
├── db_setup.sql
├── .gitignore
├── gleam.toml
└── README.md
```

### Architecture

- **Router**: Routes HTTP requests to appropriate controllers
- **Controllers**: Handle HTTP methods and manage request/response flow
- **Services**: Contain business logic and data transformation
- **Repositories**: Handle data access and storage
- **Models**: Define data structures

Here are several ways you could improve your Todo API:

## Improvements I'd like to do:

1. **Pagination**

2. **Filtering & Sorting**

3. **API Documentation**: Add OpenAPI documentation.

4. **Rate Limiting**: rate limiting to prevent abuse.

5. **Request Validation**: Better request validation beyond just checking required fields.

7. **Logging**: Better Logging with structured logs and request IDs for better debugging.

8. **Error Handling**: Implement more detailed error responses.

9. **Database Migrations**: Set up a proper migration system instead of a single setup script.

## Feature Enhancements

1. **Authentication & Authorization**: Add user accounts and protected endpoints.

2. **Task Categories/Tags**: Allow tasks to be categorized or tagged.

3. **Due Dates**: Add due dates and deadline functionality.

4. **Subtasks**: Implement hierarchical tasks with parent-child relationships.

5. **Task Comments**: Allow comments or notes on tasks.

6. **Webhooks**: Add webhook support to notify external systems of task changes.

7. **Task History**: Track the full history of changes to each task.

8. **Batch Operations**: Support bulk create/update/delete operations.

9. **Export Functionality**: Allow exporting tasks to different formats (CSV, JSON, etc.).

10. **Task Reminders**: Add functionality to set and manage reminders.

11. **Containerization**: Set up Docker to simplify deployment and development.

12. **CI/CD Pipeline**: Implement automated testing and deployment.

13. **Performance Monitoring**: Add application performance monitoring.

14. **Backup Strategy**: Implement proper database backup procedures.

15. **Horizontal Scaling**: Make the application stateless to support scaling.

16. **Environment Management**: Improve configuration for different environments.

17. **Documentation**: Enhance project documentation with diagrams and better examples.

18. **Security Scanning**: Implement vulnerability scanning in the pipeline.

19. **Observability**: Add distributed tracing for request flows.

20. **Disaster Recovery**: Create recovery procedures and test them.
