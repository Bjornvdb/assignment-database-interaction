defmodule DatabaseInteraction.Repo.Migrations.AddCurrencyPairChunksTable do
  use Ecto.Migration

  def change do
    create table "currency_pair_chunks" do
      add :from, :utc_datetime, null: false
      add :until, :utc_datetime, null: false
      add :currency_pair_id, references(:currency_pairs), null: false
    end

    create unique_index(:currency_pair_chunks, [:from, :until, :currency_pair_id], name: :unique_chunk)
  end
end
