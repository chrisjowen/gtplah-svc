defmodule Util.MapUtil do
  @exceptions [NaiveDateTime, DateTime, Geo.Point]
  @bloat [:__meta__, :__struct__, :__cardinality__, :__field__,  :__owner__]

  def from_struct(schema, modules \\ [], root \\ true)
  def from_struct(schema, modules, root) when is_map(schema) do
    additional = cond  do
      Map.has_key?(schema, :__struct__) ->
         {_, additional} = Enum.find(modules, {:none, []}, fn {module, _} -> module == schema.__struct__ end)
         additional
      true ->
        []
    end

    embeds =  additional[:embed] || []

    keys = (Map.keys(schema) -- @bloat) -- additional
    keys = case root do
      true -> keys
      false -> keys -- embeds
    end

    Map.take(schema, keys)
      |> Enum.map(&from_struct(&1, modules, schema)) |> Enum.into(%{})
  end

  def from_struct(list, modules, _) when is_list(list) do
    Enum.map(list, &from_struct(&1, modules, false))
  end

# This part looks like the mapping
  def from_struct({key, %Ecto.Association.NotLoaded{ __cardinality__: :many}}, _, _), do: {key, []}
  def from_struct({key, %Ecto.Association.NotLoaded{}}, _, _), do: {key, nil}
  def from_struct({key, %{__struct__: struct} = val}, _, _) when struct in @exceptions, do: {key, val}


  def from_struct({key, val}, modules, _) when is_map(val) or is_list(val) do
    {key, from_struct(val, modules, false)}
  end
  def from_struct(data, _, _), do: data

  def to_atom_map(map) when is_map(map),
    do: Map.new(map, fn {k, v} -> {String.to_atom(k), to_atom_map(v)} end)

  def to_atom_map(v), do: v



  # TODO: Move to protocol
  # def from_struct({key, %GtpLah.Schema.GroupMedia{} = media }, modules, _) do
  #   result = from_struct(media, modules)
  #   path = GtpLah.Media.url({media.media, media}, :thumb) |> String.replace(~r/\?[a-z0-9=]+/, "")
  #   result = Map.put(result, "thumb", path)
  #   {key, result}
  # end
  # def from_struct({key, %Geo.Point{coordinates: {lng, lat}} }, _, _), do: {key, %{ "lat" => lat, "lng" => lng}}

end
