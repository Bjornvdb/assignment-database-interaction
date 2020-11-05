defmodule DatabaseInteraction.CurrencyPair do
  use Ecto.Schema
  import Ecto.Changeset

  schema "currency_pairs" do
    field(:currency_pair, :string)
    has_many(:currency_pair_chunks, DatabaseInteraction.CurrencyPairChunk)
    has_many(:task_statuses, DatabaseInteraction.TaskStatus)
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:currency_pair])
    |> unique_constraint(:currency_pair)
  end
end
