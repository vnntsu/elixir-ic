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

  # coveralls-ignore-stop

  forward(RouterHelper.health_path(), CrawlerWeb.HealthPlug)

  ## Authentication routes

  scope "/", CrawlerWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    get("/", PageController, :index)
    get("/users/register", UserRegistrationController, :new)
    post("/users/register", UserRegistrationController, :create)
    get("/users/log_in", UserSessionController, :new)
    post("/users/log_in", UserSessionController, :create)
  end

  scope "/", CrawlerWeb do
    pipe_through([:browser, :require_authenticated_user])

    get("/home", HomeController, :index)
  end
end
