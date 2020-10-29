defmodule DatabaseInteraction.CurrencyPairChunk do
  use Ecto.Schema
  import Ecto.Changeset

  alias DatabaseInteraction.{CurrencyPair, CurrencyPairEntry}

  schema "currency_pair_chunks" do
    field(:from, :utc_datetime)
    field(:until, :utc_datetime)
    belongs_to(:currency_pair, CurrencyPair)
    has_many(:currency_pair_entries, CurrencyPairEntry)
  end

  def changeset(user, params \\ %{}, %CurrencyPair{} = cp) do
    user
    |> cast(params, [:from, :until])
    |> put_assoc(:currency_pair, cp)
    |> unique_constraint(:from, name: :unique_chunk)
  end
end
