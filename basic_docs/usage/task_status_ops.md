# Task status operations

The naming is a bit strange, but it was originally meant as a "status regarding a task". When this library was finished, we realized that the "status" part was a bit strange as the status can be calculated from the fields in `TaskRemainingChunk`.

## Retrieving a task

```elixir
iex> DatabaseInteraction.TaskStatusContext.get_by_id! 1

10:14:06.045 [debug] QUERY OK source="task_status" db=1.1ms decode=2.2ms queue=12.7ms idle=1593.0ms
SELECT t0.`id`, t0.`from`, t0.`until`, t0.`uuid`, t0.`currency_pair_id` FROM `task_status` AS t0 WHERE (t0.`id` = ?) [1]
%DatabaseInteraction.TaskStatus{
  __meta__: #Ecto.Schema.Metadata<:loaded, "task_status">,
  currency_pair: #Ecto.Association.NotLoaded<association :currency_pair is not loaded>,
  currency_pair_id: 2,
  from: ~U[2020-06-01 00:00:00Z],
  id: 1,
  task_remaining_chunks: #Ecto.Association.NotLoaded<association :task_remaining_chunks is not loaded>,
  until: ~U[2020-06-07 03:19:59Z],
  uuid: "396b5ba1-486c-44fb-83de-b80a2dcb3d38"
}
```

## Checking whether a task is done or not

`task_status_complete?/1` is a function where the parameter is either the `DatabaseInteraction.TaskStatus` struct or the id in the database.

This will check whether the task its `TaskRemainingChunk`s are `done_or_not`.

```elixir
iex(3)> DatabaseInteraction.TaskStatusContext.task_status_complete? 1
{false, %DatabaseInteraction.TaskStatus{ ... }, %{done: 165, n: 201}}
# Or if it is done
{true, %DatabaseInteraction.TaskStatus{ ... }}
```

## Generate chunk windows

Splits up a single huge window up into smaller window.

```elixir
iex> DatabaseInteraction.TaskStatusContext.generate_chunk_windows(from_in_unix, until_in_unix, window_size_in_s)
[
  %{from: ~U[2020-06-07 00:00:00Z], until: ~U[2020-06-07 03:19:59Z]},
  %{from: ~U[2020-06-06 18:00:00Z], until: ~U[2020-06-06 23:59:59Z]},
  %{from: ~U[2020-06-06 12:00:00Z], until: ~U[2020-06-06 17:59:59Z]},
  %{from: ~U[2020-06-06 06:00:00Z], until: ~U[2020-06-06 11:59:59Z]},
  %{from: ~U[2020-06-06 00:00:00Z], until: ~U[2020-06-06 05:59:59Z]},
  ...
]
```

## Creating a task with its remaining chunks

```elixir
# First displaying some variables, then output function.
iex> task_attrs
%{
  from: ~U[2020-06-01 00:00:00Z],
  until: ~U[2020-06-07 03:19:59Z],
  uuid: "e6274325-1efe-4c09-b1d6-da870ff21242"
}
iex> pair
%DatabaseInteraction.CurrencyPair{
  __meta__: #Ecto.Schema.Metadata<:loaded, "currency_pairs">,
  currency_pair: "BTC_ETH",
  currency_pair_chunks: #Ecto.Association.NotLoaded<association :currency_pair_chunks is not loaded>,
  id: 1,
  task_statuses: #Ecto.Association.NotLoaded<association :task_statuses is not loaded>
}
iex> entries
[
  %{from: ~U[2020-06-07 00:00:00Z], until: ~U[2020-06-07 03:19:59Z]},
  %{from: ~U[2020-06-06 18:00:00Z], until: ~U[2020-06-06 23:59:59Z]},
  %{from: ~U[2020-06-06 12:00:00Z], until: ~U[2020-06-06 17:59:59Z]},
  ...
]
# pattern matching on result here to show the variables later on.
iex> {:ok, result} = TaskStatusContext.create_full_task(task_attrs, pair, entries)
{:ok, ...}
iex> result
%{
  task_remaining_chunks: {25, nil},
  task_status: %DatabaseInteraction.TaskStatus{
    __meta__: #Ecto.Schema.Metadata<:loaded, "task_status">,
    currency_pair: %DatabaseInteraction.CurrencyPair{
      __meta__: #Ecto.Schema.Metadata<:loaded, "currency_pairs">,
      currency_pair: "USDT_BTC",
      currency_pair_chunks: #Ecto.Association.NotLoaded<association :currency_pair_chunks is not loaded>,
      id: 2,
      task_statuses: #Ecto.Association.NotLoaded<association :task_statuses is not loaded>
    },
    currency_pair_id: 2,
    from: ~U[2020-06-01 00:00:00Z],
    id: 3,
    task_remaining_chunks: #Ecto.Association.NotLoaded<association :task_remaining_chunks is not loaded>,
    until: ~U[2020-06-07 03:19:59Z],
    uuid: "29051d51-5532-4a73-87d8-bea9fb61225a"
  }
}
```

## Load associations

You can load the associations towards a currency pairs and their remaining chunks.

```elixir
iex> TaskStatusContext.load_association([:task_remaining_chunks, :currency_pair])
%TaskStatus{ ... all associations loaded ...}
```

## Function summary

* get_by_id!(id)
* create_task_status(attrs, %CurrencyPair{} = currency_pair)
* list_task_status, do: Repo.get_repo().all(TaskStatus)
* task_status_complete?(%TaskStatus{} = task)
* task_status_complete?(task_id)
* delete_task_status(%TaskStatus{} = task)
* delete_task_status(task_id)
* create_full_task(task_attrs, %CurrencyPair{} = currency_pair, chunks)
* load_association(%TaskStatus{} = task, list_of_options)
* delete_all_tasks()
