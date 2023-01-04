defmodule CrawlerWeb.Api.AuthErrorHandlerTest do
  use CrawlerWeb.ConnCase, async: true

  import CrawlerWeb.Gettext

  alias CrawlerWeb.Api.AuthErrorHandler

  describe "auth_error/2" do
    test "renders 401 error response", %{conn: conn} do
      conn = AuthErrorHandler.auth_error(conn, {:unauthorized, ""}, "")
      detail = gettext("Unauthorized")

      assert %{
               "errors" => [
                 %{
                   "code" => "unauthorized",
                   "detail" => ^detail
                 }
               ]
             } = json_response(conn, :unauthorized)

      assert conn.halted
    end
  end
end
