defmodule CrawlerWeb.Api.AuthErrorHandler do
  import Plug.Conn
  import Phoenix.Controller

  alias CrawlerWeb.Api.ErrorView

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_view(ErrorView)
    |> put_status(:unauthorized)
    |> render("error.json", %{
      code: "unauthorized",
      detail: "Unauthorized"
    })
  end
end
