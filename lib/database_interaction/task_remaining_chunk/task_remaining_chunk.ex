defmodule DatabaseInteraction.TaskRemainingChunk do
  use Ecto.Schema
  import Ecto.Changeset

  alias DatabaseInteraction.TaskStatus

  schema "task_remaining_chunks" do
    field(:from, :utc_datetime)
    field(:until, :utc_datetime)
    field(:done_or_not, :boolean)
    belongs_to(:task_status, TaskStatus)
  end

  def changeset(remaining_chunk, params) do
    remaining_chunk
    |> cast(params, [:from, :until, :task_status_id])
    |> cast_assoc(:task_status)
    |> unique_constraint(:from, name: :unique_task_chunk_start)
    |> unique_constraint(:until, name: :unique_task_chunk_until)
  end

  def changeset(remaining_chunk, params, %TaskStatus{} = task_status) do
    remaining_chunk
    |> cast(params, [:from, :until])
    |> put_assoc(:task_status, task_status)
    |> unique_constraint(:from, name: :unique_task_chunk_start)
    |> unique_constraint(:until, name: :unique_task_chunk_until)
  end
end
