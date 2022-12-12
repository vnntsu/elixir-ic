defmodule CrawlerWeb.UserAuthTest do
  use CrawlerWeb.ConnCase, async: true

  import CrawlerWeb.Endpoint

  alias Crawler.Account.Accounts
  alias CrawlerWeb.UserAuth

  @remember_me_cookie "_crawler_web_user_remember_me"
  @remember_me_true %{"remember_me" => "true"}
  @home_path "/home"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, config(:secret_key_base))
      |> init_test_session(%{})

    %{user: insert(:user), conn: conn}
  end

  describe "log_in_user" do
    test "given a authenticated user, store the user token in the session", %{
      conn: conn,
      user: user
    } do
      conn = UserAuth.log_in_user(conn, user)

      assert token = get_session(conn, :user_token)
      assert get_session(conn, :live_socket_id) == "users_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == @home_path
      assert Accounts.get_user_by_session_token(token)
    end

    test "given a new authenticate user, clears previous user token", %{
      conn: conn,
      user: user
    } do
      conn =
        conn
        |> put_session(:to_be_removed, "value")
        |> UserAuth.log_in_user(user)

      assert get_session(conn, :to_be_removed) == nil
    end

    test "given a unauthenticated user with remember_me is configured, writes a cookie", %{
      conn: conn,
      user: user
    } do
      conn =
        conn
        |> fetch_cookies()
        |> UserAuth.log_in_user(user, @remember_me_true)

      assert get_session(conn, :user_token) == conn.cookies[@remember_me_cookie]
      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :user_token)
      assert max_age == 60 * 60 * 24 * 60
    end
  end

  describe "fetch_current_user" do
    test "given a user with existing sesson, authenticates the user", %{conn: conn, user: user} do
      user_token = Accounts.generate_user_session_token(user)

      conn =
        conn
        |> put_session(:user_token, user_token)
        |> UserAuth.fetch_current_user([])

      assert conn.assigns.current_user.id == user.id
    end

    test "given a user cookies, authenticates the user", %{conn: conn, user: user} do
      logged_in_conn =
        conn
        |> fetch_cookies()
        |> UserAuth.log_in_user(user, @remember_me_true)

      user_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> UserAuth.fetch_current_user([])

      assert get_session(conn, :user_token) == user_token
      assert conn.assigns.current_user.id == user.id
    end

    test "given a user no matched with existing session, does not authenticate the user", %{
      conn: conn
    } do
      conn = UserAuth.fetch_current_user(conn, [])

      assert get_session(conn, :user_token) == nil
      assert conn.assigns.current_user == nil
    end
  end

  describe "redirect_if_user_is_authenticated/2" do
    test "given an authenticated user, redirects to the root page", %{conn: conn, user: user} do
      conn = conn |> assign(:current_user, user) |> UserAuth.redirect_if_user_is_authenticated([])

      assert conn.halted
      assert redirected_to(conn) == @home_path
    end

    test "given an unauthenticated user, does NOT redirect", %{conn: conn} do
      conn = UserAuth.redirect_if_user_is_authenticated(conn, [])
      assert conn.halted == false
      assert conn.status == nil
    end
  end

  describe "require_authenticated_user/2" do
    test "given an unauthenticated user, redirects to the log in page", %{conn: conn} do
      conn = conn |> fetch_flash() |> UserAuth.require_authenticated_user([])

      assert conn.halted
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
      assert get_flash(conn, :error) == "You must log in to access this page."
    end

    test "given an unauthenticated user, stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> UserAuth.require_authenticated_user([])

      assert halted_conn.halted
      assert get_session(halted_conn, :user_return_to) == "/foo"

      halted_conn_2 =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> UserAuth.require_authenticated_user([])

      assert halted_conn_2.halted
      assert get_session(halted_conn_2, :user_return_to) == "/foo?bar=baz"

      halted_conn_3 =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> UserAuth.require_authenticated_user([])

      assert halted_conn_3.halted
      assert get_session(halted_conn_3, :user_return_to) == nil
    end

    test "given an authenticated user, does NOT redirect", %{conn: conn, user: user} do
      conn = conn |> assign(:current_user, user) |> UserAuth.require_authenticated_user([])

      assert conn.halted == false
      assert conn.status == nil
    end
  end
end
