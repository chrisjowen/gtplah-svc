defmodule Util.ParamQueryGenerator do
  import Ecto.Query
  alias Util.AtomUtil

  def generate(schema, filters,  additional \\ "", order_by  \\ "") do
    filters =
      case additional do
        nil -> filters
        _ -> filters <> "|" <> additional
      end


    schema
    |> dynamic_filters(filters)
    |> dynamic_order_by(order_by)
  end

  def dynamic_order_by(queriable, ""), do: queriable

  def dynamic_order_by(queriable, order_by) do
    [field, direction] = order_by |> String.split("|")
    field = String.to_atom(field)
    direction = case direction do
      "asc" -> :asc
      _ -> :desc
    end

    queriable |> order_by([q], {^direction, field(q, ^field)})
  end


  defp dynamic_filters(schema, filters) do
    dynamics =
      filters
      |> String.split("|")
      |> Enum.filter(&(&1 != ""))
      |> collect_queries([])

    schema
    |> reduce_filters(dynamics)
  end

  def reduce_filters(queriable, dynamics) do
    dynamics
    |> Enum.reduce(queriable, fn dynamic, queriable ->
      queriable |> where([q], ^dynamic)
    end)
  end

  def collect_queries([], dynamics), do: dynamics

  def collect_queries([clause | remaining], dynamics) do
    case String.starts_with?(clause, "OR") do
      true ->
        [next_remaining, ors] = collect_ors(remaining, [String.replace(clause, "OR(", "")])

        or_dynamic =
          collect_queries(ors, [])
          |> Enum.reduce(fn query, acc ->
            dynamic([q], ^query or ^acc)
          end)

        collect_queries(next_remaining, dynamics ++ [or_dynamic])

      false ->
        collect_queries(remaining, dynamics ++ [parse_query(clause)])
    end
  end

  def collect_ors(clause, collected \\ [])

  def collect_ors([clause | remaining], collected) do
    case String.ends_with?(clause, ")") do
      true ->
        [remaining, collected ++ [String.replace(clause, ")", "")]]

      false ->
        collect_ors(remaining, collected ++ [clause])
    end
  end

  def collect_ors(remaining, collected), do: [remaining, collected]

  # TODO: Better parser

  defp parse_query(""), do: []

  defp parse_query(q) do
    case String.split(q, "=") do
      ops when length(ops) == 2 ->
        parse_ops(ops)

      _ ->
        []
    end
  end

  defp parse_ops([op, values]) do
    ops = extract_op(op)

    case ops do
      ["eq", field] ->
        dynamic([q], field(q, ^field) == ^values)

      ["in", field] ->
        values = String.split(values, ",")
        dynamic([q], field(q, ^field) in ^values)

      ["list", field] ->
          values = String.split(values, ",")
          dynamic([q], fragment("? && ?", field(q, ^field), ^values))

      ["not_in", field] ->
        values = String.split(values, ",")
        dynamic([q], field(q, ^field) not in ^values)

      ["like", field] ->
        like = "%#{values}%"
        dynamic([q], fragment("lower(?) like ?", field(q, ^field), ^like))

      ["gt", field] ->
        dynamic([q], field(q, ^field) > ^values)

      ["gte", field] ->
        dynamic([q], field(q, ^field) >= ^values)

      ["lt", field] ->
        dynamic([q], field(q, ^field) < ^values)

      ["lte", field] ->
        dynamic([q], field(q, ^field) <= ^values)

    end
  end

  defp extract_op(input) do
    regex = ~r/([a-zA-Z_-]+)\[(eq|in|like|gt|gte|lt|lte|list)\]/

    case Regex.run(regex, input) do
      [_, field, op] -> [op, AtomUtil.string_to_atom(field)]
      _ -> ["eq", AtomUtil.string_to_atom(input)]
    end
  end
end
