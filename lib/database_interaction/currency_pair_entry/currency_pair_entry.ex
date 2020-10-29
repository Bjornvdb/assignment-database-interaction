defmodule DatabaseInteraction.CurrencyPairEntry do
  use Ecto.Schema
  import Ecto.Changeset

  alias DatabaseInteraction.CurrencyPairChunk

  schema "currency_pair_entries" do
    field(:trade_id, :integer)
    field(:date, :utc_datetime)
    field(:type, :string)
    field(:rate, :string)
    field(:amount, :string)
    field(:total, :string)
    belongs_to(:currency_pair_chunk, CurrencyPairChunk)
  end

  def changeset(user, params) do
    user
    |> cast(params, [:trade_id, :date, :type, :rate, :amount, :total, :currency_pair_chunk_id])
    |> cast_assoc(:currency_pair_chunk)
    |> unique_constraint(:trade_id, name: :unique_entry)
  end

  def changeset(user, params, %CurrencyPairChunk{} = cpc) do
    user
    |> cast(params, [:trade_id, :date, :type, :rate, :amount, :total])
    |> put_assoc(:currency_pair_chunk, cpc)
    |> unique_constraint(:trade_id, name: :unique_entry)
  end
end
