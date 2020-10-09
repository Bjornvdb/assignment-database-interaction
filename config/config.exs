import Config

config :database_interaction,
  ecto_repos: [DatabaseInteraction.Repo]

import_config "#{Mix.env()}.exs"
