defmodule DatabaseInteraction.Repo.Migrations.AddCurrencyPairsTable do
  use Ecto.Migration

  def change do
    create table "currency_pairs" do
      add :currency_pair, :string, null: false
    end

    create unique_index(:currency_pairs, :currency_pair)
  end
end
