defmodule CrawlerWeb.HomeController do
  use CrawlerWeb, :controller

  def index(conn, _params), do: render(conn, "index.html")
end
