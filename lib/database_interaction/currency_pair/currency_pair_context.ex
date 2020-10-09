defmodule DatabaseInteraction.CurrencyPairContext do
  alias DatabaseInteraction.Repo
  alias DatabaseInteraction.CurrencyPair

  def list_currency_pairs, do: Repo.all(CurrencyPair)

  def create_currency_pair(attrs \\ %{}) do
    %CurrencyPair{}
    |> CurrencyPair.changeset(attrs)
    |> Repo.insert()
  end

  def delete_currency_pair(%CurrencyPair{} = cp) do
    Repo.delete(cp)
  end
end
