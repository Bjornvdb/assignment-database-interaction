# Currency pair entry operations

__Do not__ use this context. It is used internally, but shouldn't be used externally. You could use this for debugging purposes, but consider querying the database directly.

## Functions

* `CurrencyPairEntryContext.list_all_entries`
* `CurrencyPairEntryContext.create_entry(attrs \\ %{}, %CurrencyPairChunk{} = cpc)`
* `CurrencyPairEntryContext.delete_entry(%CurrencyPairEntry{} = cpe)`
