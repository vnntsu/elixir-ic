defmodule CrawlerWeb.UserRegistrationControllerTest do
  use CrawlerWeb.ConnCase, async: true

  @home_path "/home"

  describe "GET /users/register" do
    test "given an authenticated user, renders registration page", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))

      response = html_response(conn, 200)
      assert response =~ "<h1>\nRegister\n  </h1>"
      assert response =~ "Register</button>"
    end

    test "given an authenticated user, redirects to the root page", %{conn: conn} do
      conn =
        conn
        |> log_in_user(insert(:user))
        |> get(Routes.user_registration_path(conn, :new))

      assert redirected_to(conn) == @home_path
    end
  end

  describe "POST /users/register" do
    test "given valid user data, creates account and logs the user in", %{conn: conn} do
      %{email: email} = params = params_for(:user)

      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => params
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == @home_path

      # Now do a logged in request and assert on the menu
      conn2 = get(conn, @home_path)

      response = html_response(conn2, 200)
      assert response =~ email
      assert response =~ "Log out\n"
    end

    test "given invalid user data, renders errors", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => %{"email" => "with spaces", "password" => "short"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>\nRegister\n  </h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 8 character"
    end
  end
end
