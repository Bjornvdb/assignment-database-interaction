defmodule DatabaseInteraction.Repo do
  use Ecto.Repo,
    otp_app: :database_interaction,
    adapter: Ecto.Adapters.MyXQL
end
