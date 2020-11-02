defmodule DatabaseInteraction.TaskStatus do
  use Ecto.Schema
  import Ecto.Changeset

  alias DatabaseInteraction.CurrencyPair
  alias DatabaseInteraction.TaskRemainingChunk

  schema "task_status" do
    field(:from, :utc_datetime)
    field(:until, :utc_datetime)
    field(:uuid, :string)
    belongs_to(:currency_pair, CurrencyPair)
    has_many(:task_remaining_chunks, TaskRemainingChunk)
  end

  def changeset(user, params \\ %{}, %CurrencyPair{} = currency_pair) do
    user
    |> cast(params, [:from, :until])
    |> put_assoc(:currency_pair, currency_pair)
    |> unique_constraint(:from, name: :unique_task_start)
    |> unique_constraint(:until, name: :unique_task_until)
  end
end
