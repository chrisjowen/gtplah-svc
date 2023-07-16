# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :gtplah,
  ecto_repos: [GtpLah.Repo]

config :gtplah, GtpLah.SecurePipeline,
  module: GtpLah.Guardian,
  error_handler: GtpLah.AuthErrorHandler

config :gtplah, Oban,
  repo: GtpLah.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10, messages: 10, links: 20]


  config :ueberauth, Ueberauth,
  providers: [
    # facebook:
    #   {Ueberauth.Strategy.Facebook,
    #    [
    #      default_scope: "public_profile",
    #      callback_path: "/oauth/facebook/callback"
    #    ]},
    google:
      {Ueberauth.Strategy.Google,
       [
         default_scope: "email profile https://www.googleapis.com/auth/keep.readonly",
         callback_path: "/oauth/google/callback"
       ]},
    # linkedin:
    #   {Ueberauth.Strategy.LinkedIn,
    #    [callback_path: "/oauth/linkedin/callback", ignores_csrf_attack: true]}
  ],
  base_path: "/oauth"


config :ueberauth, Ueberauth.Strategy.LinkedIn.OAuth,
  client_id: System.get_env("LINKEDIN_CLIENT_ID"),
  client_secret: System.get_env("LINKEDIN_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: System.get_env("FACEBOOK_CLIENT_ID"),
  client_secret: System.get_env("FACEBOOK_CLIENT_SECRET")


config :cors_plug,
  origin: [
    "https://news.crowdsolve.ai/"
  ],
  max_age: 86400,
  methods: ["GET", "POST", "DELETE", "PUT", "OPTIONS", "HEAD"]

config :gtplah, GtpLah.Guardian,
  issuer: "gtplah",
  secret_key: "SIs0ZqwWwih49ZMx5CeXI2eY0q5Mv6n9gYz1xKvatjBdlpL4Pfo7HAgn/Gug2qtr5"

# Configures the endpoint
config :gtplah, GtpLah.Web.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: GtpLah.Web.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: GtpLah.PubSub,
  live_view: [signing_salt: "gSpMyCEo"]

config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :geo_postgis,
  json_library: Jason

config :openai,
  api_key: System.get_env("OPEN_AI_KEY"),
  organization_key: "org-2cJ3cEThmAglpQRKQr3X2W64",
  http_options: [recv_timeout: 120_000]

import_config "#{config_env()}.exs"
