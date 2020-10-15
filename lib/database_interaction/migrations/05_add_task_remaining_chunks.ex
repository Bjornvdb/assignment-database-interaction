defmodule DatabaseInteraction.Repo.Migrations.AddTaskRemainingChunks do
  use Ecto.Migration

  def change do
    create table("task_remaining_chunks") do
      add(:from, :utc_datetime, null: false)
      add(:until, :utc_datetime, null: false)
      add(:done_or_not, :bool, default: false)
      add(:task_status_id, references(:task_status), null: false)

      timestamps()
    end

    create(
      unique_index(:task_remaining_chunks, [:from, :task_status_id],
        name: :unique_task_chunk_start
      )
    )

    create(
      unique_index(:task_remaining_chunks, [:until, :task_status_id],
        name: :unique_task_chunk_until
      )
    )
  end
end
