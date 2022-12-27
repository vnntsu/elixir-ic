defmodule CrawlerWeb.Plugs.SetCurrentUserTest do
  use CrawlerWeb.ConnCase, async: true

  import CrawlerWeb.Plugs.SetCurrentUser

  alias CrawlerWeb.Plugs.SetCurrentUser

  describe "call/2" do
    test "given a user, retrieves user data from session", %{conn: conn} do
      _ = SetCurrentUser.init({})
      created_user = insert(:user)

      conn =
        conn
        |> Plug.Conn.put_private(:guardian_default_resource, created_user)
        |> call(%{})

      assert conn.assigns.current_user.id == created_user.id
    end

    test "given no user, doesn't retrieve user data from session", %{conn: conn} do
      conn = call(conn, %{})

      assert conn.assigns.current_user == nil
    end
  end
end
