defmodule DatabaseInteraction.Repo do
  @repo Application.get_env(:database_interaction, :repo)

  @error_message "Configure your repository in your config.exs / dev.exs! E.g. \n" <>
                   "config :database_interaction, repo: MyApp.Repo,"

  def get_repo, do: @repo || raise(@error_message)
end
