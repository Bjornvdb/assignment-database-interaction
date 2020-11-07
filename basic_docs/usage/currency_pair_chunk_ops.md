# Currency pair **chunk** operations

An overview of the sample data (everything at midnight unless otherwise specified):

```text
######### #########    ######### #########    ######### #########
# 01/06 # # 03/06 #    # 05/06 # # 06/06 #    # 08/06 # # 10/06 #
######### #########    ######### #########    ######### #########
|  PRESENT IN DB  |    |  PRESENT IN DB  |    |  PRESENT IN DB  |
-----------------------------------------------------------------

As you can see, the data between 03/06 => 05/06 and 06/06 => 08/06 is missing.

Overview of the unix timestamps:
# 1590969600 => 01/06
# 1591056000 => 02/06
# 1591142400 => 03/06
# 1591228800 => 04/06
# 1591315200 => 05/06
# 1591401600 => 06/06
# 1591488000 => 07/06
# 1591574400 => 08/06
# 1591660800 => 09/06
# 1591747200 => 10/06
```

```elixir
# Functions to make these chunks directly (this is a manual debug function! Don't use this directly):

# chunk that'll contain 1 June - 3 June
chunk_1 = %{from: DateTime.from_unix!(1590969600) , until: DateTime.from_unix!(1591142400)}

# chunk that'll contain 5 June - 6 June
chunk_2 = %{from: DateTime.from_unix!(1591315200), until: DateTime.from_unix!(1591401600)}

# chunk that'll contain 8 June - 10 June
chunk_3 = %{from: DateTime.from_unix!(1591574400), until: DateTime.from_unix!(1591747200)}

{:ok, _c1} = DatabaseInteraction.CurrencyPairChunkContext.create_chunk(chunk_1, pair, :i_am_aware_that_i_should_not_use_this_directly)
{:ok, _c2} = DatabaseInteraction.CurrencyPairChunkContext.create_chunk(chunk_2, pair, :i_am_aware_that_i_should_not_use_this_directly)
{:ok, _c3} = DatabaseInteraction.CurrencyPairChunkContext.create_chunk(chunk_3, pair, :i_am_aware_that_i_should_not_use_this_directly)

# You can assume in the following sections that this data is present.
```

## Generate missing chunks

Play a bit around with this function. This function will generate, by default, tuples of timeframes (missing chunks) where the last second is excluded.

E.g. a 5 minute timeframe will become 4 minutes and 59 seconds

```elixir
iex>pair = DatabaseInteraction.CurrencyPairContext.get_pair_by_name("BTC_USDT")
...
iex>from = DateTime.from_unix!(1591747500)
~U[2020-06-10 00:05:00Z]
iex>until = DateTime.from_unix!(1591747800)
~U[2020-06-10 00:10:00Z]
iex>DatabaseInteraction.CurrencyPairChunkContext.generate_missing_chunks(from, until)
[{~U[2020-06-10 00:05:00Z], ~U[2020-06-10 00:09:59Z]}]
```

Here is an example with chunks that are already present in the database:

```elixir
iex>pair = DatabaseInteraction.CurrencyPairContext.get_pair_by_name("BTC_USDT")
...
iex> from = DateTime.from_unix!(1590969599)
~U[2020-05-31 23:59:59Z]
iex> until = DateTime.from_unix!(1591747200)
~U[2020-06-10 00:00:00Z]
iex> DatabaseInteraction.CurrencyPairChunkContext.generate_missing_chunks(from, until, pair)
[
  {~U[2020-05-31 23:59:59Z], ~U[2020-05-31 23:59:59Z]},
  {~U[2020-06-03 00:00:01Z], ~U[2020-06-04 23:59:59Z]},
  {~U[2020-06-06 00:00:01Z], ~U[2020-06-07 23:59:59Z]}
]
```

## Selecting chunks between a timeframe

```elixir
iex> pair = DatabaseInteraction.CurrencyPairContext.get_pair_by_name("BTC_ETH")
...
iex> from = DateTime.from_unix!(1590969599)
...
iex> until = DateTime.from_unix!(1591747200)
...
iex> DatabaseInteraction.CurrencyPairChunkContext.select_chunks( from, until, pair)

13:34:43.300 [debug] QUERY OK source="currency_pair_chunks" db=1.4ms idle=1421.1ms
SELECT c0.`id`, c0.`from`, c0.`until`, c0.`currency_pair_id` FROM `currency_pair_chunks` AS c0 WHERE (((c0.`currency_pair_id` = ?) AND (((c0.`from` < ?) AND (c0.`until` >= ?)) OR (c0.`from` >= ?))) AND (((c0.`until` > ?) AND (c0.`from` <= ?)) OR (c0.`until` <= ?))) ORDER BY c0.`from` [1, ~U[2020-05-31 23:59:59Z], ~U[2020-05-31 23:59:59Z], ~U[2020-05-31 23:59:59Z], ~U[2020-06-10 00:00:00Z], ~U[2020-06-10 00:00:00Z], ~U[2020-06-10 00:00:00Z]]
[
  %DatabaseInteraction.CurrencyPairChunk{ ... },
  %DatabaseInteraction.CurrencyPairChunk{ ... },
  %DatabaseInteraction.CurrencyPairChunk{ ... },
  ...
]
```

## Create chunk w/ entries

The idea is that you convert a `TaskRemainingChunk` into an "actual" chunk with data. That's why, in order to create this (with the entries), you have to pass in a `TaskRemainingChunk` struct with entries. The entries are a list of `AssignmentMessages.ClonedEntry` structs.

```elixir
iex> task_that_has_been_cloned = %DatabaseInteraction.TaskRemainingChunk{ ... }
...
iex> some_fake_entries = [%AssignmentMessages.ClonedEntry{ ... }, %AssignmentMessages.ClonedEntry{ ... }, %AssignmentMessages.ClonedEntry{ ... }, ... ]
...
iex> CurrencyPairChunkContext.create_chunk_with_entries(task_that_has_been_cloned, some_fake_entries)
{:ok, %{ ...} = a lot of stuff that you don't need worry about}
```

## Functions summary

* list_all_chunks()
* create_chunk(attrs \\ %{}, %CurrencyPair{} = cp, @awareness_atom) => __don't use this directly.__
* create_chunk_with_entries(%TaskRemainingChunk{} = trc, list_of_entries)
* delete_chunk(%CurrencyPairChunk{} = cpc)
* select_chunks(%DateTime{} = from, %DateTime{} = until, %CurrencyPair{} = cp)
* generate_missing_chunks(%DateTime{} = from, %DateTime{} = until, %CurrencyPair{} = cp)
