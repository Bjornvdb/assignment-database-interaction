defmodule DatabaseInteraction.CurrencyPairContext do
  alias DatabaseInteraction.CurrencyPair

  def get_pair(id), do: DatabaseInteraction.Repo.get_repo().get(CurrencyPair, id)
  def get_pair!(id), do: DatabaseInteraction.Repo.get_repo().get!(CurrencyPair, id)

  def get_pair_by_name(pair_name),
    do: DatabaseInteraction.Repo.get_repo().get_by(CurrencyPair, currency_pair: pair_name)

  def list_currency_pairs, do: DatabaseInteraction.Repo.get_repo().all(CurrencyPair)

  def create_currency_pair(attrs \\ %{}) do
    %CurrencyPair{}
    |> CurrencyPair.changeset(attrs)
    |> DatabaseInteraction.Repo.get_repo().insert()
  end

  def delete_currency_pair(%CurrencyPair{} = cp) do
    DatabaseInteraction.Repo.get_repo().delete(cp)
  end
end
