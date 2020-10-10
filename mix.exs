defmodule DatabaseInteraction.MixProject do
  use Mix.Project

  def project do
    [
      app: :database_interaction,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:ecto_sql, "~> 3.4"}]
  end
end
