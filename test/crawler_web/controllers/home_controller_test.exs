defmodule CrawlerWeb.HomeControllerTest do
  use CrawlerWeb.ConnCase, async: true

  describe "GET /home" do
    test "given an authenticated user, renders the home page", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.home_path(conn, :index))

      assert conn.assigns.current_user.id == user.id

      response = html_response(conn, 200)
      assert response =~ gettext("Home")
      assert response =~ gettext("Please choose a CSV file:")
    end

    test "give an unauthenticated user, renders the log in page", %{conn: conn} do
      conn =
        conn
        |> get(Routes.home_path(conn, :index))
        |> get(Routes.user_session_path(conn, :new))

      assert html_response(conn, 200) =~ "#{gettext("Log in")}</a>"
    end
  end
end
