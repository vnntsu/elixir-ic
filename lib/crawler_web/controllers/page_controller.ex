# credo:disable-for-this-file CompassCredoPlugin.Check.DoSingleExpression
defmodule CrawlerWeb.PageController do
  use CrawlerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
