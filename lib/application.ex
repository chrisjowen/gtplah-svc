defmodule GtpLah.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GtpLah.Repo,
      GtpLah.Web.Telemetry,
      {Phoenix.PubSub, name: GtpLah.PubSub},
      GtpLah.Web.Endpoint,
      {Oban, Application.fetch_env!(:gtplah, Oban)},
      {Registry, keys: :unique, name: Registry.Conversations}
    ]

    opts = [strategy: :one_for_one, name: GtpLah.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GtpLah.Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
