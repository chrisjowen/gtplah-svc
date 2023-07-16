defmodule GtpLah.BaseController do
  defmacro __using__(ops \\ []) do
    quote do
      use GtpLah.Web, :controller
      action_fallback GtpLah.FallbackController
      alias GtpLah.Eventing.Repo
      import GtpLah.BaseController
      import Ecto.Query
      require Logger
      import Guardian.Plug

      @ops unquote(ops)

      if(Keyword.has_key?(@ops, :schema)) do
        defcrud(
          Keyword.get(@ops, :schema),
          Keyword.get(@ops, :only, [:show, :index, :create, :update, :delete]),
          Keyword.get(@ops, :add_user, true)
        )
      end

      defp extract_preloads(params) do
        Map.get(params, "preloads", "")
        |> String.split(",")
        |> Enum.filter(&(&1 != ""))
        |> Enum.map(&to_preload/1)
      end

      defp to_preload(assoc) when is_list(assoc) do
        [h | t] = assoc

        case t do
          [] -> string_to_atom(h)
          _ -> {string_to_atom(h), Enum.map(t, &string_to_atom/1)}
        end
      end

      defp to_preload(assoc) do
        String.split(assoc, ".") |> to_preload
      end

      def string_to_atom(str) do
        try do
          String.to_existing_atom(str)
        rescue
          ArgumentError -> String.to_atom(str)
        end
      end
    end
  end

  defmacro defcrud(schema, routes \\ [:show, :index, :create, :update, :delete], _add_user \\ true) do
    quote do
      alias GtpLah.Eventing.Repo
      import Ecto.Query
      import Guardian.Plug

      if(Enum.member?(unquote(routes), :show)) do
        def show(conn, %{"id" => id} = params) do
          result = Repo.get(unquote(schema), id) |> Repo.preload(extract_preloads(params))
          json(conn, result)
        end

        defoverridable show: 2
      end

      if(Enum.member?(unquote(routes), :index)) do
        def index(conn, params) do
          result = search(conn, params)
          |> Repo.paginate(params)

          json(conn, result)
        end

        defoverridable index: 2

        defp search(conn, params) do
          preloads = extract_preloads(params)
          query = Map.get(params, "query", "")

          order_by =
            Map.get(params, "order_by", Map.get(conn.assigns, :order_by, "updated_at|desc"))

          result =
            from(q in unquote(schema),
              preload: ^preloads
            )
            |> Util.ParamQueryGenerator.generate(query, conn.assigns[:q], order_by)
        end

        defoverridable search: 2
      end

      if(Enum.member?(unquote(routes), :create)) do
        def create(conn, params) do
          params =
            case current_resource(conn) do
              nil -> params
              user -> Map.put(params, "created_by_id", user.id)
            end

          with {:ok, entity} <- Repo.change(unquote(schema), params) |> Repo.insert() do
            assign(conn, :entity, entity) |> json(entity)
          end
        end

        defoverridable create: 2
      end

      if(Enum.member?(unquote(routes), :update)) do
        def update(conn, %{"id" => id} = params) do
          entity = Repo.get(unquote(schema), id)

          params =
            case current_resource(conn) do
              nil -> params
              user -> Map.put(params, "updated_by_id", user.id)
            end

          with {:ok, updated} <-
                 entity
                 |> unquote(schema).changeset(params)
                 |> Repo.update() do
            assign(conn, :entity, updated) |> json(updated)
          end
        end

        defoverridable update: 2
      end

      if(Enum.member?(unquote(routes), :delete)) do
        def delete(conn, %{"id" => id}) do
          item = Repo.get(unquote(schema), id)
          Repo.delete!(item)
          json(conn, %{ok: id})
        end

        defoverridable delete: 2
      end
    end
  end
end
