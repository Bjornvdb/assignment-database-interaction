# Task Remaining Chunk operations

TODO

## functions summary

* get_chunk_by(%TaskStatus{} = task, from_unix, until_unix)
* get_chunk_by(task_id, from_unix, until_unix)
* changeset_mark_as_done(%TaskRemainingChunk{} = trc)
* mark_as_done(%TaskRemainingChunk{} = trc)
* halve_chunk(%TaskStatus{} = task_id, from_unix, until_unix)
* halve_chunk(task_id, from_unix, until_unix)
      when is_binary(task_id) or is_integer(task_id)
* load_association(%TaskRemainingChunk{} = remaining_chunk, list_of_options) when is_list(list_of_options)
* get_all_unfinished_remaining_tasks()
* get_all_unfinished_remaining_tasks_for_pair(%DatabaseInteraction.CurrencyPair{} = pair)
