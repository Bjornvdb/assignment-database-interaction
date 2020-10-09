defmodule DatabaseInteraction.Migrations do
  use Ecto.Migration

  def change do
    DatabaseInteraction.Repo.Migrations.AddCurrencyPairsTable.change()
    DatabaseInteraction.Repo.Migrations.AddCurrencyPairChunksTable.change()
    DatabaseInteraction.Repo.Migrations.AddCurrencyPairEntriesTable.change()
  end
end
