defmodule GtpLah.Web.Router do
  use GtpLah.Web, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug(GtpLah.SecurePipeline)
  end


  scope "/integrations", GtpLah.Integrations do
    pipe_through(:api)
    # Unsecured
    post("/whatsapp", WhatsAppController, :hook)
    get("/whatsapp", WhatsAppController, :hook)
  end


  @read_routes [:index, :show]
  @write_routes [:create, :update, :delete]
  @read_write_routes @read_routes ++ @write_routes

  scope "/api", GtpLah do
    pipe_through(:api)
    # Unsecured
    post("/login", LoginController, :login)
    post("/register", LoginController, :register)

  end

  scope "/api", GtpLah do
    pipe_through([:api, :auth])
    resources("/message", MessageController, only: @read_write_routes)
    resources("/link", LinkController, only: @read_write_routes)
    resources "/user", UserController, only: @read_write_routes do
      resources "/integration", UserIntegrationController, only: @read_write_routes
    end
    resources("/intent", IntentController, only: @read_write_routes)
    resources("/note", NoteController, only: @read_write_routes)

    post("/ai/:type", AIController, :execute)
  end


  scope "/oauth", GtpLah do
    pipe_through :browser
    get("/:provider", OAuthController, :request)
    get("/:provider/callback", OAuthController, :callback)
    post("/:provider/callback", OAuthController, :callback)
    delete("/logout", OAuthController, :delete)
  end


  # Enables LiveDashboard only for development
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through([:fetch_session, :protect_from_forgery])
      live_dashboard("/dashboard", metrics: GtpLah.Web.Telemetry)
    end
  end
end
