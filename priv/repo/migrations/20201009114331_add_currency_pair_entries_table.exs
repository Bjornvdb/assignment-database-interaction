defmodule DatabaseInteraction.Repo.Migrations.AddCurrencyPairEntriesTable do
  use Ecto.Migration

  def change do
    create table "currency_pair_entries" do
      add :trade_id, :integer, null: false
      add :date, :utc_datetime, null: false
      add :type, :string, null: false
      add :rate, :string, null: false
      add :amount, :string, null: false
      add :total, :string, null: false
      add :currency_pair_chunk_id, references(:currency_pair_chunks), null: false
    end

    create unique_index :currency_pair_entries, [:currency_pair_chunk_id, :trade_id], name: :unique_entry
  end
end
