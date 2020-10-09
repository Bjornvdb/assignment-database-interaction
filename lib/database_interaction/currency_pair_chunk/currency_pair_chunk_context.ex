defmodule DatabaseInteraction.CurrencyPairChunkContext do
  alias DatabaseInteraction.Repo
  alias DatabaseInteraction.{CurrencyPair, CurrencyPairChunk}

  def list_all_chunks, do: Repo.all(CurrencyPairChunk)

  def create_chunk(attrs \\ %{}, %CurrencyPair{} = cp) do
    %CurrencyPairChunk{}
    |> CurrencyPairChunk.changeset(attrs, cp)
    |> Repo.insert()
  end

  def delete_chunk(%CurrencyPairChunk{} = cpc) do
    Repo.delete(cpc)
  end
end
