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
  @impl true
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

  @impl true
  def handle_call(:view, _from, list) do
    {:reply, list, list}
  end

  @impl true
  def handle_call({:delete, name}, _from, list) do
    deleted_task = Enum.find(list, {:error, :not_found}, fn element -> element.name == name end)
    {:reply, {:ok, deleted_task}, list -- [deleted_task]}
  end

  @impl true
  def handle_call({:find, name}, _from, list) do
    task = Enum.find(list, {:error, :not_found}, fn element -> element.name == name end)
    {:reply, {:ok, task}, list}
  end

  @impl true
  def handle_call({:done, name}, _from, list) do
    task_to_change = Enum.find(list, {:error, :not_found}, fn element -> element.name == name end)
    if task_to_change != {:error, :not_found} do
      new_state= %{task_to_change | done: true}
      new_list = [new_state | Enum.reduce(list, [], fn x, acc -> if x.name != name do [x | acc] else acc end end)]
      {:reply, {:ok, new_state}, new_list}
    #[all_tasks | new_state] = Enum.reduce(list, [[], []], fn x, acc -> if x.name != name do [x | Enum.at(acc, 0)] else [ %{x | done: true} | Enum.at(acc, 1)] end end)
    #new_state = Enum.reduce(list, [[%Task{done: true}], [%Task{}]], fn x, acc -> if x.name != name do [x | all_tasks] else [ %{x | done: true} | done_task] end end)
    #{:reply, {:ok, new_state}, [new_state, new_list]}
    #{:reply, {:ok, new_state}, [new_state] ++ [all_tasks]}
    else
      {:reply, task_to_change, list}
    end
  end

  @impl true
  def handle_call(:sort, _from, list) do
    sorted_list = Enum.sort_by(list, &(&1.created_at), :desc)
    {:reply, {:ok, sorted_list}, list}
  end

  @impl true
  def init(list) do
    IO.inspect({:ok, list})
  end
end
