# Currency pair operations

## Add a currency pair

```elixir
iex> DatabaseInteraction.CurrencyPairContext.create_currency_pair(%{currency_pair: "BTC_USDC"})
{:ok,
 %DatabaseInteraction.CurrencyPair{
   __meta__: #Ecto.Schema.Metadata<:loaded, "currency_pairs">,
   currency_pair: "BTC_USDC",
   currency_pair_chunks: #Ecto.Association.NotLoaded<association :currency_pair_chunks is not loaded>,
   id: 2,
   task_statuses: #Ecto.Association.NotLoaded<association :task_statuses is not loaded>
 }}
```

## Retrieve currency pair information

```elixir
iex> DatabaseInteraction.CurrencyPairContext.get_pair! 2
%DatabaseInteraction.CurrencyPair{
  __meta__: #Ecto.Schema.Metadata<:loaded, "currency_pairs">,
  currency_pair: "BTC_ETH",
  currency_pair_chunks: #Ecto.Association.NotLoaded<association :currency_pair_chunks is not loaded>,
  id: 2,
  task_statuses: #Ecto.Association.NotLoaded<association :task_statuses is not loaded>
}

iex> DatabaseInteraction.CurrencyPairContext.get_pair_by_name "BTC_ETH"
%DatabaseInteraction.CurrencyPair{
  __meta__: #Ecto.Schema.Metadata<:loaded, "currency_pairs">,
  currency_pair: "BTC_ETH",
  currency_pair_chunks: #Ecto.Association.NotLoaded<association :currency_pair_chunks is not loaded>,
  id: 2,
  task_statuses: #Ecto.Association.NotLoaded<association :task_statuses is not loaded>
}
```

## Loading associations

While this library can abstract away a part of the database, it isn't able to abstract it completely away. By default relations are lazily loaded, this means that you have to do an explicit (small) query to obtain the extra information that you need.

The currency pair has an association (a has_many association) with `task_statuses` and `currency_pair_chunks`. You can load all the association information like so:

```elixir
iex> an_existing_pair = DatabaseInteraction.CurrencyPairContext.list_currency_pairs |> List.first
%DatabaseInteraction.CurrencyPair{ ... }
iex> DatabaseInteraction.CurrencyPairContext.load_association(an_existing_pair, [:currency_pair_chunks, :task_statuses])
%DatabaseInteraction.CurrencyPair{
  __meta__: #Ecto.Schema.Metadata<:loaded, "currency_pairs">,
  currency_pair: "BTC_ETH",
  currency_pair_chunks: [
    %DatabaseInteraction.CurrencyPairChunk{ ... },
    %DatabaseInteraction.CurrencyPairChunk{ ... },
    %DatabaseInteraction.CurrencyPairChunk{ ... },
    %DatabaseInteraction.CurrencyPairChunk{ ... },
    ...
  ],
  task_statuses: [
    %DatabaseInteraction.TaskStatus{
      __meta__: #Ecto.Schema.Metadata<:loaded, "task_status">,
      currency_pair: #Ecto.Association.NotLoaded<association :currency_pair is not loaded>,
      currency_pair_id: 1,
      from: ~U[2020-06-01 00:00:00Z],
      id: 2,
      task_remaining_chunks: #Ecto.Association.NotLoaded<association :task_remaining_chunks is not loaded>,
      until: ~U[2020-06-07 03:19:59Z],
      uuid: "7e72a2ea-a6eb-44ba-ab56-58b852f79e4e"
    }
  ]
}
```

## Creating a pair

```elixir
iex>DatabaseInteraction.CurrencyPairContext.create_currency_pair %{ignored_value: "A totally not interesting value", currency_pair: "MyPair"}

13:26:55.947 [debug] QUERY OK db=5.4ms queue=0.9ms idle=1117.4ms
INSERT INTO `currency_pairs` (`currency_pair`) VALUES (?) ["MyPair"]
{:ok,
 %DatabaseInteraction.CurrencyPair{ 
   __meta__: #Ecto.Schema.Metadata<:loaded, "currency_pairs">,
   currency_pair: "MyPair",
   currency_pair_chunks: #Ecto.Association.NotLoaded<association :currency_pair_chunks is not loaded>,
   id: 4,
   task_statuses: #Ecto.Association.NotLoaded<association :task_statuses is not loaded>
 }}

# Now if I'd execute this again
iex> DatabaseInteraction.CurrencyPairContext.create_currency_pair %{ignored_value: "A totally not interesting value", currency_pair: "MyPair"}

13:27:42.669 [debug] QUERY ERROR db=4.0ms queue=1.1ms idle=1840.4ms
INSERT INTO `currency_pairs` (`currency_pair`) VALUES (?) ["MyPair"]
{:error,
 #Ecto.Changeset<
   action: :insert,
   changes: %{currency_pair: "MyPair"},
   errors: [
     currency_pair: {"has already been taken",
      [
        constraint: :unique,
        constraint_name: "currency_pairs_currency_pair_index"
      ]}
   ],
   data: #DatabaseInteraction.CurrencyPair<>,
   valid?: false
 >}
```

## Deleting a pair

```elixir
iex> DatabaseInteraction.CurrencyPairContext.get_pair_by_name("MyPair") |> DatabaseInteraction.CurrencyPairContext.delete_currency_pair

13:29:05.585 [debug] QUERY OK source="currency_pairs" db=2.2ms queue=0.1ms idle=1750.5ms
SELECT c0.`id`, c0.`currency_pair` FROM `currency_pairs` AS c0 WHERE (c0.`currency_pair` = ?) ["MyPair"]
 
13:29:05.592 [debug] QUERY OK db=5.0ms queue=1.3ms idle=1753.4ms
DELETE FROM `currency_pairs` WHERE `id` = ? [4]
{:ok,
 %DatabaseInteraction.CurrencyPair{ 
   __meta__: #Ecto.Schema.Metadata<:deleted, "currency_pairs">,
   currency_pair: "MyPair",
   currency_pair_chunks: #Ecto.Association.NotLoaded<association :currency_pair_chunks is not loaded>,
   id: 4,
   task_statuses: #Ecto.Association.NotLoaded<association :task_statuses is not loaded>
 }}
```

## Function list

* get_pair(id)
* get_pair!(id)
* get_pair_by_name(pair_name)
* list_currency_pairs()
* create_currency_pair(attrs \\ %{})
* delete_currency_pair(%CurrencyPair{} = cp)
* load_association(%CurrencyPair{} = pair, list_of_options) when is_list(list_of_options)
