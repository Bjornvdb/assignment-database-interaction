defmodule DatabaseInteraction.CurrencyPairEntryContext do
  alias DatabaseInteraction.Repo
  alias DatabaseInteraction.{CurrencyPairChunk, CurrencyPairEntry}

  def list_all_entries, do: Repo.all(CurrencyPairEntry)

  def create_entry(attrs \\ %{}, %CurrencyPairChunk{} = cpc) do
    %CurrencyPairEntry{}
    |> CurrencyPairEntry.changeset(attrs, cpc)
    |> Repo.insert()
  end

  def delete_entry(%CurrencyPairEntry{} = cpe) do
    Repo.delete(cpe)
  end
end
