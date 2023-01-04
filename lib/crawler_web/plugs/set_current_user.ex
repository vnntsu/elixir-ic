defmodule CrawlerWeb.Plugs.SetCurrentUser do
  import Plug.Conn

  alias Crawler.Account.Guardian.Plug

  def init(_options), do: nil

  def call(conn, _params) do
    current_user = Plug.current_resource(conn)
    assign(conn, :current_user, current_user)
  end
end
