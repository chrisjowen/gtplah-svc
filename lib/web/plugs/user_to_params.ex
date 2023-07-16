defmodule GtpLah.Plug.UserToParams do
  import Guardian.Plug

  def init(options) do
    options
  end

  def call(conn, _opts) do
    case current_resource(conn) do
      nil ->
        conn

      user ->
        %{conn | params: Map.put(conn.params, "user_id", user.id)}
    end
  end
end
