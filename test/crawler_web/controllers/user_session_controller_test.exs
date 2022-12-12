defmodule CrawlerWeb.UserSessionControllerTest do
  use CrawlerWeb.ConnCase, async: true

  import CrawlerWeb.Gettext

  @home_path "/home"

  describe "GET /users/log_in" do
    test "given an unauthenticated user, renders log in page", %{conn: conn} do
      conn = get(conn, Routes.user_session_path(conn, :new))

      response = html_response(conn, 200)
      assert response =~ "<h1>\nLog in\n  </h1>"
      assert response =~ "#{gettext("Log in")}</button>"
    end

    test "given an authenticated user, redirects to the root page", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.user_session_path(conn, :new))

      assert redirected_to(conn) == @home_path
    end
  end

  describe "POST /users/log_in" do
    test "given a valid user data, redirects to the root page", %{conn: conn} do
      user = insert(:user)

      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{"email" => user.email, "password" => user.password}
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == @home_path

      conn_2 = get(conn, @home_path)
      response = html_response(conn_2, 200)
      assert response =~ user.email
      assert response =~ "Log out"
    end

    test "given a valid user data with remember me flag, redirects to the root page", %{
      conn: conn
    } do
      user = insert(:user)

      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{
            "email" => user.email,
            "password" => user.password,
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_crawler_web_user_remember_me"]
      assert redirected_to(conn) == @home_path
    end

    test "given invalid uesr data, emits error message", %{conn: conn} do
      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{"email" => "some email", "password" => "invalid password"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>\nLog in\n  </h1>"
      assert response =~ "Invalid email or password"
    end

    test "given valid data with return to, logs the user in", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> init_test_session(user_return_to: "/foo/bar")
        |> post(Routes.user_session_path(conn, :create), %{
          "user" => %{"email" => user.email, "password" => user.password}
        })

      assert redirected_to(conn) == "/foo/bar"
    end
  end
end
