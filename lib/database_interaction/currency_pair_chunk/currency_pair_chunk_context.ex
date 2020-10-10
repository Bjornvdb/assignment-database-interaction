defmodule DatabaseInteraction.CurrencyPairChunkContext do
  alias DatabaseInteraction.{CurrencyPair, CurrencyPairChunk}

  def list_all_chunks, do: DatabaseInteraction.Repo.get_repo().all(CurrencyPairChunk)

  def create_chunk(attrs \\ %{}, %CurrencyPair{} = cp) do
    %CurrencyPairChunk{}
    |> CurrencyPairChunk.changeset(attrs, cp)
    |> DatabaseInteraction.Repo.get_repo().insert()
  end

  def delete_chunk(%CurrencyPairChunk{} = cpc) do
    DatabaseInteraction.Repo.get_repo().delete(cpc)
  end
end
