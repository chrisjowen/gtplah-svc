defmodule GtpLah.OAuthController do
  use GtpLah.Web, :controller


  plug Ueberauth

  def callback(%{assigns: %{ueberauth_failure: failure}} = conn, _params) do
    # conn
    # |> redirect(external: System.get_env("UI_BASE_URL") <> "/login?error=#{failure.reason}")


    conn |> json(%{error: failure.reason})

  end

  def callback(%{assigns: %{ueberauth_auth: _}} = conn, _params) do
    conn |> json(:ok)

  end

end
