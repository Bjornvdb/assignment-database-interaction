# Setup / config

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

Your tables should exist! Now start your repository module under your application supervisor (probably `application.ex`).
