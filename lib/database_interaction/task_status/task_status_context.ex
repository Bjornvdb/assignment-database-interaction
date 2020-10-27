defmodule DatabaseInteraction.TaskStatusContext do
  alias DatabaseInteraction.{TaskStatus, TaskRemainingChunk}
  alias DatabaseInteraction.CurrencyPair
  alias DatabaseInteraction.Repo
  alias Ecto.Multi

  def get_by_id!(id) do
    Repo.get_repo().get(TaskStatus, id)
  end

  def create_task_status(attrs, %CurrencyPair{} = currency_pair) do
    %TaskStatus{}
    |> TaskStatus.changeset(attrs, currency_pair)
    |> Repo.get_repo().insert()
  end

  def list_task_status, do: Repo.get_repo().all(TaskStatus)

  def create_full_task(task_attrs, %CurrencyPair{} = currency_pair, chunks) do
    Multi.new()
    |> Multi.insert(
      :task_status,
      TaskStatus.changeset(%TaskStatus{}, task_attrs, currency_pair)
    )
    |> Multi.insert_all(:task_remaining_chunks, TaskRemainingChunk, fn %{task_status: ts} ->
      Enum.map(chunks, fn chunk ->
        Map.put(chunk, :task_status_id, ts.id)
        |> Map.put(:inserted_at, NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))
        |> Map.put(:updated_at, NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))
      end)
    end)
    |> Repo.get_repo().transaction()
  end

  def load_association(%TaskStatus{} = task, list_of_options) when is_list(list_of_options) do
    Repo.get_repo().preload(task, list_of_options)
  end

  def delete_all_tasks() do
    Repo.get_repo().delete_all(TaskRemainingChunk)
    Repo.get_repo().delete_all(TaskStatus)
  end
end
