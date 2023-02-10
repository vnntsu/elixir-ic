defmodule CrawlerWeb.Router do
  use CrawlerWeb, :router

  import CrawlerWeb.UserAuth

  alias CrawlerWeb.RouterHelper

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {CrawlerWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  # coveralls-ignore-start
  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :api_auth do
    plug CrawlerWeb.Api.AuthPipeline
  end

  # coveralls-ignore-stop

  forward(RouterHelper.health_path(), CrawlerWeb.HealthPlug)

  ## Authentication routes

  scope "/", CrawlerWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    get("/", PageController, :index)

    scope "/users" do
      get("/register", UserRegistrationController, :new)
      post("/register", UserRegistrationController, :create)
      get("/log_in", UserSessionController, :new)
      post("/log_in", UserSessionController, :create)
    end
  end

  scope "/", CrawlerWeb do
    pipe_through([:browser, :require_authenticated_user])

    get("/home", HomeController, :index)
    resources("/keyword", KeywordController, only: [:create, :show])
  end

  ## api

  scope "/api", CrawlerWeb, as: :api do
    pipe_through :api

    scope "/v1", Api.V1, as: :v1 do
      post("/log_in", UserSessionController, :create)
      post("/register", UserRegistrationController, :create)
    end
  end

  scope "/api", CrawlerWeb, as: :api do
    pipe_through [:api, :api_auth]

    scope "/v1", Api.V1, as: :v1 do
      resources("/keyword", KeywordController, only: [:index, :create, :show])
    end
  end
end
