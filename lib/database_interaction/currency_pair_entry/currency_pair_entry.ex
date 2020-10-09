defmodule DatabaseInteraction.CurrencyPairEntry do
  use Ecto.Schema
  import Ecto.Changeset

  alias DatabaseInteraction.CurrencyPairChunk

  schema "users" do
    field(:trade_id, :integer)
    field(:date, :utc_datetime)
    field(:type, :string)
    field(:rate, :string)
    field(:amount, :string)
    field(:total, :string)
    belongs_to(:currency_pair_chunk, CurrencyPairChunk)
  end

  def changeset(user, params \\ %{}, %CurrencyPairChunk{} = cpc) do
    user
    |> cast(params, [:trade_id, :date, :type, :rate, :amount, :total])
    |> put_assoc(:currency_pair_chunk, cpc)
  end
end
