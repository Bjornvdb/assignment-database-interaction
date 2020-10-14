defmodule DatabaseInteraction.Migrations do
  use Ecto.Migration

  def change do
    DatabaseInteraction.Repo.Migrations.AddCurrencyPairs.change()
    DatabaseInteraction.Repo.Migrations.AddCurrencyPairChunks.change()
    DatabaseInteraction.Repo.Migrations.AddCurrencyPairEntries.change()
    DatabaseInteraction.Repo.Migrations.AddTaskStatus.change()
    DatabaseInteraction.Repo.Migrations.AddTaskRemainingChunks.change()
  end
end
