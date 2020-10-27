defmodule DatabaseInteraction.TaskRemainingChunkContext do
  import Ecto.Query
  alias DatabaseInteraction.{CurrencyPairContext, TaskRemainingChunk, TaskStatus}
  # alias DatabaseInteraction.TaskStatus
  # alias DatabaseInteraction.Repo

  # def create_task_remaining_chunk(attrs, %TaskStatus{} = task) do
  #   %TaskRemainingChunk{}
  #   |> TaskRemainingChunk.changeset(attrs, task)
  #   |> Repo.get_repo().insert()
  # end

  # def list_task_status, do: Repo.get_repo().all(TaskRemainingChunk)

  def get_chunk_by(%TaskStatus{} = task, from_unix, until_unix) do
    from = DateTime.from_unix!(from_unix)
    until = DateTime.from_unix!(until_unix)

    # from(trc in DatabaseInteraction.TaskRemainingChunk,
    #   where: trc.from == ^from,
    #   where: trc.until == ^until,
    #   where: trc.task_status_id == ^task
    # )
    # |> DatabaseInteraction.Repo.get_repo().get_by(TaskRemainingChunk, [from: from, until: until, task_status_id: task.id])
    DatabaseInteraction.Repo.get_repo().get_by(TaskRemainingChunk,
      from: from,
      until: until,
      task_status_id: task.id
    )
  end

  def halve_chunk(%TaskStatus{} = task_id, from_unix, until_unix) do
    tdiff = until_unix - from_unix

    new_t1 = div(tdiff, 2) + from_unix
    new_t2 = new_t1 + 1

    from = DateTime.from_unix!(from_unix)
    until = DateTime.from_unix!(until_unix)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:task_remaining_chunk, fn _repo, _ ->
      case get_chunk_by(task_id, from_unix, until_unix) do
        nil -> {:error, :not_found}
        chunk -> {:ok, chunk}
      end
    end)
    |> Ecto.Multi.delete(:delete, fn %{task_remaining_chunk: tr} ->
      tr
    end)
    |> Ecto.Multi.insert_all(:add_halved_chunks, TaskRemainingChunk, fn _ ->
      base = %{
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        task_status_id: task_id.id,
        from: nil,
        until: nil
      }

      first_half = %{base | from: from, until: DateTime.from_unix!(new_t1)}
      second_half = %{base | until: until, from: DateTime.from_unix!(new_t2)}
      [first_half, second_half]
    end)
    |> DatabaseInteraction.Repo.get_repo().transaction()
  end

  def halve_chunk(task_id, from_unix, until_unix)
      when is_binary(task_id) or is_integer(task_id) do
    task_id
    |> DatabaseInteraction.TaskStatusContext.get_by_id!()
    |> halve_chunk(from_unix, until_unix)
  end

  def load_association(%TaskRemainingChunk{} = remaining_chunk, list_of_options)
      when is_list(list_of_options) do
    DatabaseInteraction.Repo.get_repo().preload(remaining_chunk, list_of_options)
  end

  def get_all_unfinished_remaining_tasks() do
    CurrencyPairContext.list_currency_pairs()
    |> Enum.map(&get_all_unfinished_remaining_tasks_for_pair/1)
    |> List.flatten()
    |> Enum.map(fn remaining_chunk ->
      load_association(remaining_chunk, task_status: [:currency_pair])
    end)
  end

  def get_all_unfinished_remaining_tasks_for_pair(%DatabaseInteraction.CurrencyPair{} = pair) do
    from(trc in DatabaseInteraction.TaskRemainingChunk,
      join: ts in DatabaseInteraction.TaskStatus,
      join: cp in DatabaseInteraction.CurrencyPair,
      on: cp.id == ts.currency_pair_id,
      on: ts.id == trc.task_status_id,
      where: cp.id == ^pair.id
    )
    |> DatabaseInteraction.Repo.get_repo().all()
  end
end
