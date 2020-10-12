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

TODO...
