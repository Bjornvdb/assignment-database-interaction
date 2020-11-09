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

## Creating a task with its remaining chunks


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
