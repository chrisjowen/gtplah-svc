defmodule GtpLah.MixProject do
  use Mix.Project

  def project do
    [
      app: :gtplah,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers:  Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end


  def application do
    [
      mod: {GtpLah.Application, []},
      extra_applications: [:logger, :runtime_tools,  :httpoison]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]


  defp deps do
    [
      {:phoenix, "~> 1.6.6"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:esbuild, "~> 0.3", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.5"},
      {:geo_postgis, "~> 3.4"},
      {:scrivener_ecto, "~> 2.0"},
      {:httpoison, "~> 2.0"},
      {:phoenix_api_toolkit, "~> 2.0.0"},
      {:cors_plug, "~> 3.0"},
      {:openai, github: "mgallo/openai.ex"},
      {:oban, "~> 2.14"},
      {:pbkdf2_elixir, "~> 1.0"},
      {:ueberauth, "~> 0.10"},
      {:ueberauth_google, "~> 0.10", override: true},
      {:comeonin_ecto_password, "~> 3.0.0"},
      {:guardian, "~> 2.0"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:floki, "~> 0.34.0"}

    ]
  end


  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.seed": ["run priv/repo/seeds.exs"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end
end
