-- Tasks Table Schema
CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster status-based queries
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);

-- Constraint to enforce valid status values
ALTER TABLE tasks DROP CONSTRAINT IF EXISTS chk_valid_status;
ALTER TABLE tasks ADD CONSTRAINT chk_valid_status
    CHECK (status IN ('todo', 'in_progress', 'done'));

-- Function to automatically update timestamps
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to update timestamps on record updates
DROP TRIGGER IF EXISTS update_tasks_timestamp ON tasks;
CREATE TRIGGER update_tasks_timestamp
BEFORE UPDATE ON tasks
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

-- Add some sample data (optional)
INSERT INTO tasks (title, description, status)
VALUES 
    ('Set up project', 'Initialize the project structure and dependencies', 'done'),
    ('Create API endpoints', 'Implement the RESTful API endpoints', 'in_progress'),
    ('Write documentation', 'Document the API usage and setup process', 'todo')
ON CONFLICT DO NOTHING;