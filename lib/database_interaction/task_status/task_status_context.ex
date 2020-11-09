defmodule DatabaseInteraction.TaskStatusContext do
  alias DatabaseInteraction.{TaskStatus, TaskRemainingChunk}
  alias DatabaseInteraction.CurrencyPair
  alias DatabaseInteraction.Repo
  alias Ecto.Multi
  import Ecto.Query, only: [from: 2]

  def get_by_id!(id) do
    Repo.get_repo().get(TaskStatus, id)
  end

  def list_task_status, do: Repo.get_repo().all(TaskStatus)

  def generate_chunk_windows(from_in_unix, until_in_unix, window_size_in_s) do
    from_unix = from_in_unix
    until_unix = until_in_unix

    window = window_size_in_s
    chunks = Kernel.ceil((until_unix - from_unix) / window) - 1

    Enum.reduce_while(0..chunks, [], fn n, acc ->
      new_from = from_unix + n * window
      new_until = from_unix + (n + 1) * window - 1

      case new_until >= until_unix do
        true ->
          entry = %{from: DateTime.from_unix!(new_from), until: DateTime.from_unix!(until_unix)}
          {:halt, [entry | acc]}

        false ->
          entry = %{from: DateTime.from_unix!(new_from), until: DateTime.from_unix!(new_until)}
          {:cont, [entry | acc]}
      end
    end)
  end

  def task_status_complete?(%TaskStatus{} = task) do
    loaded_task = load_association(task, [:task_remaining_chunks, :currency_pair])

    case Enum.all?(loaded_task.task_remaining_chunks, & &1.done_or_not) do
      true ->
        {true, loaded_task}

      false ->
        details =
          Enum.reduce(loaded_task.task_remaining_chunks, %{n: 0, done: 0}, fn
            %TaskRemainingChunk{done_or_not: true}, a -> %{a | n: a.n + 1, done: a.done + 1}
            %TaskRemainingChunk{done_or_not: false}, a -> %{a | n: a.n + 1}
          end)

        {false, loaded_task, details}
    end
  end

  def task_status_complete?(task_id) do
    task_id |> get_by_id! |> task_status_complete?()
  end

  def delete_task_status(%TaskStatus{} = task) do
    from(tr in TaskRemainingChunk, where: tr.task_status_id == ^task.id)
    |> Repo.get_repo().delete_all()

    # loaded_task = load_association(task, [:task_remaining_chunks])

    Repo.get_repo().delete(task)
  end

  def delete_task_status(task_id) do
    task_id |> get_by_id! |> delete_task_status()
  end

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
