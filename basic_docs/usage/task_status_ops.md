# Task status operations

...

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
