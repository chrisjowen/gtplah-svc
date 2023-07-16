defmodule Schema.ScopeQueries do
  import Ecto.Query

  def created_by(query, user_id) do
    from q in query,
      where: q.created_by_id == ^user_id
  end


end
