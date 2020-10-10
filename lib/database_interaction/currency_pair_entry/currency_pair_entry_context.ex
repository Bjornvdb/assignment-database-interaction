defmodule DatabaseInteraction.CurrencyPairEntryContext do
  alias DatabaseInteraction.{CurrencyPairChunk, CurrencyPairEntry}

  def list_all_entries, do: DatabaseInteraction.Repo.get_repo().all(CurrencyPairEntry)

  def create_entry(attrs \\ %{}, %CurrencyPairChunk{} = cpc) do
    %CurrencyPairEntry{}
    |> CurrencyPairEntry.changeset(attrs, cpc)
    |> DatabaseInteraction.Repo.get_repo().insert()
  end

  def delete_entry(%CurrencyPairEntry{} = cpe) do
    DatabaseInteraction.Repo.get_repo().delete(cpe)
  end
end
