# DatabaseInteraction

## installation

Add the dependency and your favorite SQL driver (only tested with MyXQL...):

```elixir
  defp deps do
    [
      {:database_interaction,
       git: "https://github.com/distributed-applications-2021/assignment-database-interaction", branch: "main"},
       {:myxql, "~> 0.4.3"}
    ]
  end
```

Create your repository module, e.g. :

```elixir
# lib/repo.ex
# replace MyApp and ":my_app"
defmodule MyApp.Repo do
  use Ecto.Repo,
    otp_app: :my_app,
    adapter: Ecto.Adapters.MyXQL
end
```

Also add the following configuration:

```elixir
# e.g. in config.exs or dev.exs if you're using import_config "#{Mix.env()}.exs"
import Config

# replace ":my_app" and MyApp
config :my_app,
  ecto_repos: [MyApp.Repo]

# replace ":my_app" and MyApp
config :my_app, MyApp.Repo,
  database: "assignmnent_crypto",
  username: "YOUR_USERNAME",
  password: "YOUR_PASSWORD",
  hostname: "localhost"

# replace MyApp
config :database_interaction, repo: MyApp.Repo
```

Run `mix deps.get`. This will add `ecto_sql` for you, and you'll be able to use the commands `mix ecto.*`.

Run:

```elixir
mix ecto.gen.migration add_database_interaction_tables
```

Then add the following content:

```elixir
# Replace MyApp with your application name!
defmodule MyApp.Repo.Migrations.AddDatabaseInteractionTables do
  use Ecto.Migration

  def change do
    DatabaseInteraction.Migrations.change()
  end
end
```

This will create the necessary migrations. Try it out with:

```bash
mix ecto.drop && mix ecto.create && mix ecto.migrate --log-sql
```

Your tables should exist!

## Usage

### Currency pair operations

#### Add a currency pair

```elixir
iex> DatabaseInteraction.CurrencyPairContext.create_currency_pair(%{currency_pair: "BTC_USDC"})
{:ok,
 %DatabaseInteraction.CurrencyPair{
   __meta__: #Ecto.Schema.Metadata<:loaded, "currency_pairs">,
   currency_pair: "BTC_USDC",
   currency_pair_chunks: #Ecto.Association.NotLoaded<association :currency_pair_chunks is not loaded>,
   id: 2
 }}
```

#### Retrieve currency pair information

```elixir
iex> DatabaseInteraction.CurrencyPairContext.get_pair! 2
%DatabaseInteraction.CurrencyPair{
  __meta__: #Ecto.Schema.Metadata<:loaded, "currency_pairs">,
  currency_pair: "BTC_USDC",
  currency_pair_chunks: #Ecto.Association.NotLoaded<association :currency_pair_chunks is not loaded>,
  id: 2
}

iex> DatabaseInteraction.CurrencyPairContext.get_pair_by_name "BTC_USDC"
%DatabaseInteraction.CurrencyPair{
  __meta__: #Ecto.Schema.Metadata<:loaded, "currency_pairs">,
  currency_pair: "BTC_USDC",
  currency_pair_chunks: #Ecto.Association.NotLoaded<association :currency_pair_chunks is not loaded>,
  id: 2
}
```

### Currency pair **chunk** operations

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

#### Generate missing chunks

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

TODO...
