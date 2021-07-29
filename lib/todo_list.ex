defmodule TodoList do
  use GenServer

  #Client
  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def create_task(pid, name) do
    GenServer.call(pid, {:create, name})
  end

  def all_tasks(pid) do
    GenServer.call(pid, :view)
  end

  def find_task(pid, name) do
    GenServer.call(pid, {:find, name})
  end

  def delete_task(pid, name) do
    GenServer.call(pid, {:delete, name})
  end

  def done(pid, name) do
    GenServer.call(pid, {:done, name})
  end

  def all_by_created_at_tasks(pid) do
    GenServer.call(pid, :sort)
  end

  #Server
  def handle_call({:create, name}, _from, list) do
    if Enum.find(list, fn element ->
      element.name == name
    end) != nil do
      {:reply, {:error, :already_exists}, list}
    else
      new_task = %TodoTask{name: name, created_at: NaiveDateTime.local_now()}
      {:reply, {:ok, new_task}, [new_task | list]}
    end
  end

  def handle_call(:view, _from, list) do
    {:reply, list, list}
  end

  def handle_call({:delete, name}, _from, list) do
    deleted_task = Enum.find(list, {:error, :not_found}, fn element -> element.name == name end)
    {:reply, {:ok, deleted_task}, list -- [deleted_task]}
  end

  def handle_call({:find, name}, _from, list) do
    task = Enum.find(list, {:error, :not_found}, fn element -> element.name == name end)
    {:reply, {:ok, task}, list}
  end

  def handle_call({:done, name}, _from, list) do
    new_state= %{Enum.find(list, {:error, :not_found}, fn element -> element.name == name end) | done: true}
    new_list = [new_state | list -- [Enum.find(list, {:error, :not_found}, fn element -> element.name == name end)]]
    {:reply, {:ok, new_state}, new_list}
  end

  def handle_call(:sort, _from, list) do
    sorted_list = Enum.sort_by(list, &(&1.created_at), :desc)
    {:reply, {:ok, sorted_list}, list}
  end

  def init(list) do
    IO.inspect({:ok, list})
  end
end
