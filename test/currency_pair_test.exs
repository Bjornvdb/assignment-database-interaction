defmodule DatabaseInteraction.CurrencyPairTest do
  use DatabaseInteraction.DataCase

  alias DatabaseInteraction.CurrencyPairContext

  @valid_attrs %{currency_pair: "BTC_USDT"}

  def currency_pair_fixture(attrs \\ %{}) do
    {:ok, cp} =
      attrs
      |> Enum.into(@valid_attrs)
      |> CurrencyPairContext.create_currency_pair()

    cp
  end

  test "Can create & list currency pairs" do
    result = currency_pair_fixture()
    assert result.currency_pair == "BTC_USDT"
    assert length(CurrencyPairContext.list_currency_pairs()) == 1
  end

  test "Can delete currency pairs" do
    assert length(CurrencyPairContext.list_currency_pairs()) == 0
    result = currency_pair_fixture()
    assert length(CurrencyPairContext.list_currency_pairs()) == 1
    CurrencyPairContext.delete_currency_pair(result)
    assert length(CurrencyPairContext.list_currency_pairs()) == 0
  end
end
