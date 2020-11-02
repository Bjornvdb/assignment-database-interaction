defmodule DatabaseInteraction.Repo.Migrations.AddTaskStatus do
  use Ecto.Migration

  def change do
    create table("task_status") do
      add(:from, :utc_datetime, null: false)
      add(:until, :utc_datetime, null: false)
      add(:uuid, :string, null: false)
      add(:currency_pair_id, references(:currency_pairs), null: false)
    end

    create(unique_index(:task_status, [:from, :currency_pair_id], name: :unique_task_start))
    create(unique_index(:task_status, [:until, :currency_pair_id], name: :unique_task_until))
    create(unique_index(:task_status, :uuid))
  end
end
