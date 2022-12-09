defmodule CrawlerWeb.HomeControllerTest do
  use CrawlerWeb.ConnCase, async: true

  describe "GET /home" do
    test "given existing session, renders home page", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.home_path(conn, :index))

      assert conn.assigns.current_user.id == user.id
      assert html_response(conn, 200) =~ "Home"
    end

    test "give non-existing session, renders log in page", %{conn: conn} do
      conn =
        conn
        |> get(Routes.home_path(conn, :index))
        |> get(Routes.user_session_path(conn, :new))

      assert html_response(conn, 200) =~ "Log in</a>"
    end
  end
end
