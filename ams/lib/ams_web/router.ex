defmodule AmsWeb.Router do
  use AmsWeb, :router

  use Kaffy.Routes, scope: "/admin", pipe_through: [:browser, :auth, :ensure_auth]
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end
  pipeline :api do
    plug :accepts, ["json"]
  end

  # Our pipeline implements "maybe" authenticated. We'll use the `:ensure_auth` below for when we need to make sure someone is logged in.
  pipeline :auth do
    plug Ams.Accounts.Pipeline
  end

  # We use ensure_auth to fail if there is no one logged in
  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/", AmsWeb do
    pipe_through [:browser, :auth]

    get "/", PageController, :index
    get "/login", SessionController, :new
    post "/login", SessionController, :login
    get "/logout", SessionController, :logout
  end

  scope "/admin", AmsWeb do
    pipe_through [:browser, :auth, :ensure_auth]
    get "/p/analytic", AnalyticController, :new
    post "/p/analytic/test", AnalyticController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", AmsWeb do
  #   pipe_through :api
  # end
  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router
    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: AmsWeb.Telemetry
    end
  end
end
