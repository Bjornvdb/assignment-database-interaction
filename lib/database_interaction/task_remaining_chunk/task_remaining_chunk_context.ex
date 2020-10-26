defmodule DatabaseInteraction.TaskRemainingChunkContext do
  import Ecto.Query
  alias DatabaseInteraction.{TaskRemainingChunkContext, CurrencyPairContext}
  # alias DatabaseInteraction.TaskStatus
  # alias DatabaseInteraction.Repo

  # def create_task_remaining_chunk(attrs, %TaskStatus{} = task) do
  #   %TaskRemainingChunk{}
  #   |> TaskRemainingChunk.changeset(attrs, task)
  #   |> Repo.get_repo().insert()
  # end

  # def list_task_status, do: Repo.get_repo().all(TaskRemainingChunk)

  def load_association(%DatabaseInteraction.TaskRemainingChunk{} = pair, list_of_options)
      when is_list(list_of_options) do
    DatabaseInteraction.Repo.get_repo().preload(pair, list_of_options)
  end

  def get_all_unfinished_remaining_tasks() do
    CurrencyPairContext.list_currency_pairs()
    |> Enum.map(&TaskRemainingChunkContext.get_all_unfinished_remaining_tasks_for_pair/1)
    |> List.flatten()
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
