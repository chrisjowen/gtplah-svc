defmodule GtpLah.ClearOrderBy do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _) do
    assign(conn, :order_by, "")
  end
end
