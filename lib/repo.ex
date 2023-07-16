defmodule GtpLah.Repo do
  use Ecto.Repo,
    otp_app: :gtplah,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10

  def change(principal, params) when is_atom(principal) and is_map(params) do
    apply(principal, :changeset, [struct(principal), params])
  end
end

defmodule GtpLah.Eventing.Repo do
  alias GtpLah.Repo
  # alias GtpLah.{Build, Step, Log}
  # alias GtpLah.{BranchUpdaterChannel, BuildUpdaterChannel,
  #                     StepUpdaterChannel}

  # Delgate most stuff to Repo
  def config(), do: Repo.config()
  def transaction(opts \\ [], fun), do: Repo.transaction(opts, fun)
  def rollback(value), do: Repo.rollback(value)
  def all(queryable, opts \\ []), do: Repo.all(queryable, opts)
  def get(queryable, id, opts \\ []), do: Repo.get(queryable, id, opts)
  def get!(queryable, id, opts \\ []), do: Repo.get!(queryable, id, opts)
  def get_by(queryable, clauses, opts \\ []), do: Repo.get_by(queryable, clauses, opts)
  def get_by!(queryable, clauses, opts \\ []), do: Repo.get_by!(queryable, clauses, opts)
  def one(queryable, opts \\ []), do: Repo.one(queryable, opts)
  def one!(queryable, opts \\ []), do: Repo.one!(queryable, opts)
  def insert_all(schema, entries, opts \\ []), do: Repo.insert_all(schema, entries, opts)
  def update_all(queryable, updates, opts \\ []), do: Repo.update_all(queryable, updates, opts)
  def delete_all(queryable, opts \\ []), do: Repo.delete_all(queryable, opts)
  def insert_or_update(changeset, opts \\ []), do: Repo.insert_or_update(changeset, opts)
  def insert_or_update!(changeset, opts \\ []), do: Repo.insert_or_update!(changeset, opts)
  def delete(struct, opts \\ []), do: Repo.delete(struct, opts)
  def delete!(struct, opts \\ []), do: Repo.delete!(struct, opts)
  def preload(struct_or_structs, preloads), do: Repo.preload(struct_or_structs, preloads)
  def paginate(a, b), do: Repo.paginate(a, b)

  def change(principal, params) when is_atom(principal) and is_map(params) do
    apply(principal, :changeset, [struct(principal), params])
  end

  # Custom functions
  def insert(queryable, opts \\ []) do
    handle_repo_return(Repo.insert(queryable, opts), :insert)
  end

  def insert!(queryable, opts \\ []) do
    model = Repo.insert!(queryable, opts)
    model_event(model, :insert)
    model
  end

  def update(queryable, opts \\ []) do
    handle_repo_return(Repo.update(queryable, opts), :update)
  end

  def update!(queryable, opts \\ []) do
    model = Repo.update!(queryable, opts)
    model_event(model, :update)
    model
  end

  defp handle_repo_return(return, type) do
    case return do
      {:ok, model} = good ->
        model_event(model, type)
        good

      otherwise ->
        otherwise
    end
  end

  defp model_event(model, mode) do
    IO.inspect("Model event for #{inspect(model)} in #{inspect(mode)} mode")
    # Que.add(GtpLah.Workers.SchemaUpdatedWorker, [model, mode])
  end
end
