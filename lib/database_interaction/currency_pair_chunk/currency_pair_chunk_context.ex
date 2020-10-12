defmodule DatabaseInteraction.CurrencyPairChunkContext do
  alias DatabaseInteraction.{CurrencyPair, CurrencyPairChunk}
  import Ecto.Query, only: [from: 2]

  def list_all_chunks, do: DatabaseInteraction.Repo.get_repo().all(CurrencyPairChunk)

  def create_chunk(
        attrs \\ %{},
        %CurrencyPair{} = cp,
        :i_am_aware_that_i_should_not_use_this_directly
      ) do
    %CurrencyPairChunk{}
    |> CurrencyPairChunk.changeset(attrs, cp)
    |> DatabaseInteraction.Repo.get_repo().insert()
  end

  def create_chunk_with_entries(_attrs \\ %{}, %CurrencyPair{} = _cp, _list_of_entries) do
    raise "TODO"
  end

  def delete_chunk(%CurrencyPairChunk{} = cpc) do
    DatabaseInteraction.Repo.get_repo().delete(cpc)
  end

  def select_chunks(%DateTime{} = from, %DateTime{} = until, %CurrencyPair{} = cp) do
    DateTime.to_unix(until) > DateTime.to_unix(from) || raise "Until should be bigger than from."

    from(r in CurrencyPairChunk,
      where:
        r.currency_pair_id == ^cp.id and
          ((r.from < ^from and r.until >= ^from) or r.from >= ^from) and
          ((r.until > ^until and r.from <= ^until) or r.until <= ^until),
      order_by: r.from
    )
    |> DatabaseInteraction.Repo.get_repo().all()
  end

  def generate_missing_chunks(%DateTime{} = from, %DateTime{} = until, %CurrencyPair{} = cp) do
    DateTime.to_unix(until) > DateTime.to_unix(from) || raise "Until should be bigger than from."
    metainfo = %{start: from, end: until, tasks: [], point_in_time: from}

    select_chunks(from, until, cp)
    |> Enum.concat([:finalize])
    |> Enum.reduce(metainfo, fn
      :finalize, metainfo ->
        # End is exclusive the last second
        case DateTime.to_unix(metainfo.point_in_time) <= DateTime.to_unix(metainfo.end) - 1 do
          true ->
            new_task = {metainfo.point_in_time, DateTime.add(metainfo.end, -1, :second)}
            %{metainfo | tasks: [new_task | metainfo.tasks]}

          false ->
            metainfo
        end

      %{from: c_f, until: c_u}, metainfo ->
        pit_unix = DateTime.to_unix(metainfo.point_in_time)
        c_f_unix = DateTime.to_unix(c_f)

        cond do
          pit_unix >= metainfo.end ->
            metainfo

          # skip and start looking from current chunk its until
          c_f_unix <= pit_unix ->
            %{metainfo | point_in_time: DateTime.add(c_u, 1, :second)}

          c_f_unix > pit_unix ->
            new_task = {metainfo.point_in_time, DateTime.add(c_f, -1, :second)}
            new_pit = DateTime.add(c_u, 1, :second)
            %{metainfo | point_in_time: new_pit, tasks: [new_task | metainfo.tasks]}
        end
    end)
    |> Map.fetch!(:tasks)
    |> Enum.reverse()
  end
end

# Below code was just for debugging. Run this from your own project that uses this as a dependency

# alias ClonerDirector.Repo
# alias DatabaseInteraction.CurrencyPairChunk

# import Ecto.Query, only: [from: 2]

# # This should return the above 3 chunks
# from = DateTime.from_unix!(1591056000) # 02/06
# until = DateTime.from_unix!(1591660800) # 09/06
# query = from r in CurrencyPairChunk, where: ((r.from < ^from and r.until > ^from) or r.from >= ^from) and ((r.until > ^until and r.from < ^until) or r.until <= ^until ), order_by: r.from
# result = Repo.all query

# # This should return the above last 2 chunks
# from = DateTime.from_unix!(1591315201) # 05/06
# until = DateTime.from_unix!(1591660800) # 09/06
# query = from r in CurrencyPairChunk, where: ((r.from < ^from and r.until > ^from) or r.from >= ^from) and ((r.until > ^until and r.from < ^until) or r.until <= ^until )
# result = Repo.all query

# # This should return the above first 2 chunks
# from = DateTime.from_unix!(1590969600) # 01/06
# until = DateTime.from_unix!(1591315201) # 05/06
# query = from r in CurrencyPairChunk, where: ((r.from < ^from and r.until > ^from) or r.from >= ^from) and ((r.until > ^until and r.from < ^until) or r.until <= ^until )
# result = Repo.all query

# # This should return one chunk
# from = DateTime.from_unix!(1590969601) # 01/06 + 1 sec
# until = DateTime.from_unix!(1591142399) # 03/06 - 1 sec
# query = from r in CurrencyPairChunk, where: ((r.from < ^from and r.until > ^from) or r.from >= ^from) and ((r.until > ^until and r.from < ^until) or r.until <= ^until )
# result = Repo.all query
