require 'sinatra'
require 'sinatra/contrib/all' if development?
require 'PG'

require 'pry-byebug'

get '/tasks' do
  # Get all tasks from DB
  sql = "SELECT id, name, details FROM tasks;"
  @tasks = run_sql(sql)
  erb :index
end

get '/tasks/new' do
  # Render a form for creating a new task
  erb :new
end

post '/tasks' do
  # Creates a new task from the posted data
  name = params[:name]
  details = params[:details]
  sql = "INSERT INTO tasks (name, details) VALUES (
      #{sql_string(name)},
      #{sql_string(details)}
    )"
  run_sql(sql)
  redirect to('/tasks')
end

get '/tasks/:id' do
  # Grab task from the DB where id is :id
  @id = params[:id]
  sql = "SELECT name, details FROM tasks WHERE id = #{params[:id].to_i}"
  @task = run_sql(sql).first
  erb :show
end

get '/tasks/:id/edit' do
  # Render a form for editing the task with id :id
  @id = params[:id]
  sql = "SELECT name, details FROM tasks WHERE id = #{params[:id].to_i}"
  @task = run_sql(sql).first
  erb :edit
end

post '/tasks/:id' do
  # Updates the details of the task from the posted data
  name = params[:name]
  details = params[:details]
  id = params[:id]
  sql = "UPDATE tasks SET (name, details) = (
      #{sql_string(name)},
      #{sql_string(details)}
    ) WHERE id = #{id.to_i}"
  run_sql(sql)
  redirect to('/tasks')
end

get '/tasks/:id/delete' do
  # Deletes the task
  id = params[:id]
  sql = "DELETE FROM tasks WHERE id = #{id.to_i}"
  run_sql(sql)
  redirect to('/tasks')
end



def sql_string(value)
  "'#{value.to_s.gsub("'", "''")}'"
end

def run_sql(sql)
  db = PG.connect(dbname: 'todo', host: 'localhost')
  result = db.exec(sql)
  db.close
  result
end