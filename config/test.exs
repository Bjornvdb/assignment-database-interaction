import Config

# config :database_interaction,
#   ecto_repos: [DatabaseInteraction.Repo]

# config :database_interaction, DatabaseInteraction.Repo,
#   database: "assignmnent_crypto",
#   username: "root",
#   password: "t",
#   hostname: "localhost"

config :database_interaction, DatabaseInteraction.Repo, pool: Ecto.Adapters.SQL.Sandbox
