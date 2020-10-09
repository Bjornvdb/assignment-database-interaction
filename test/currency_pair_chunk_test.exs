defmodule DatabaseInteraction.CurrencyPairChunkTest do
  use DatabaseInteraction.DataCase

  alias DatabaseInteraction.{CurrencyPairChunkContext, CurrencyPairContext}

  @ts_hr_ago ((DateTime.utc_now() |> DateTime.to_unix()) - 60 * 60 * 24) |> DateTime.from_unix!()
  @ts_now DateTime.utc_now() |> DateTime.truncate(:second)

  @valid_cp_attrs %{currency_pair: "BTC_USDT"}
  @valid_cpc_attrs %{from: @ts_hr_ago, until: @ts_now}

  def currency_pair_fixture(attrs \\ %{}) do
    {:ok, cp} =
      attrs
      |> Enum.into(@valid_cp_attrs)
      |> CurrencyPairContext.create_currency_pair()

    cp
  end

  def chunk_fixture(attrs \\ %{}, cp) do
    {:ok, cpc} =
      attrs
      |> Enum.into(@valid_cpc_attrs)
      |> CurrencyPairChunkContext.create_chunk(cp)

    cpc
  end

  test "Can create & list chunks" do
    assert length(CurrencyPairChunkContext.list_all_chunks()) == 0
    result = currency_pair_fixture() |> chunk_fixture()
    assert result.from == @ts_hr_ago
    assert result.until == @ts_now
    assert length(CurrencyPairChunkContext.list_all_chunks()) == 1
  end

  test "Can delete chunks" do
    result = currency_pair_fixture() |> chunk_fixture()
    assert length(CurrencyPairChunkContext.list_all_chunks()) == 1
    CurrencyPairChunkContext.delete_chunk(result)
    assert length(CurrencyPairChunkContext.list_all_chunks()) == 0
  end
end
