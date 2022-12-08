defmodule CrawlerWeb.Router do
  use CrawlerWeb, :router

  import CrawlerWeb.UserAuthController

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

  scope "/", CrawlerWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  ## Authentication routes

  scope "/", CrawlerWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    get("/users/register", UserRegistrationController, :new)
    post("/users/register", UserRegistrationController, :create)
  end
end
