defmodule CrawlerWeb.Api.V1.UserRegistrationControllerTest do
  use CrawlerWeb.ConnCase, async: true

  alias Crawler.Account.Guardian

  describe "POST create/2" do
    test "given valid user credentials, returns access token", %{conn: conn} do
      email = "new_email@gmail.com"

      conn =
        post(conn, Routes.api_v1_user_registration_path(conn, :create), %{
          email: email,
          password: "12345678"
        })

      assert %{
               "data" => %{
                 "attributes" => %{
                   "email" => ^email,
                   "token" => _
                 },
                 "id" => _,
                 "relationships" => %{},
                 "type" => "user_registration"
               },
               "included" => []
             } = json_response(conn, 200)
    end

    test "given invalid user credentials, returns error response", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_registration_path(conn, :create), %{})

      assert json_response(conn, 422) == %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "detail" => gettext("Email or password is missing")
                 }
               ]
             }
    end

    test "given existing user email, returns error response", %{conn: conn} do
      %{email: email, password: password} = insert(:user)

      conn =
        post(conn, Routes.api_v1_user_registration_path(conn, :create), %{
          email: email,
          password: password
        })

      assert json_response(conn, 400) == %{
               "errors" => [
                 %{
                   "code" => "bad_request",
                   "detail" => gettext("Email has already been taken"),
                   "source" => %{"parameter" => "email"}
                 }
               ]
             }
    end

    test "given an invalid user with password is less than 8 characters, returns error response", %{
      conn: conn
    } do
      conn =
        post(conn, Routes.api_v1_user_registration_path(conn, :create), %{
          email: "email@gmail.com",
          password: "123456"
        })

      assert json_response(conn, 400) == %{
               "errors" => [
                 %{
                   "code" => "bad_request",
                   "detail" => gettext("Password should be at least 8 character(s)"),
                   "source" => %{"parameter" => "password"}
                 }
               ]
             }
    end

    test "given an invalid user credentials with multiple errors, returns error response", %{
      conn: conn
    } do
      %{email: email} = insert(:user)

      conn =
        post(conn, Routes.api_v1_user_registration_path(conn, :create), %{
          email: email,
          password: "123456"
        })

      assert errors = json_response(conn, 400)

      assert %{
               "code" => "bad_request",
               "detail" => gettext("Password should be at least 8 character(s)"),
               "source" => %{"parameter" => "password"}
             } in errors["errors"] == true

      assert %{
               "code" => "bad_request",
               "detail" => gettext("Email has already been taken"),
               "source" => %{"parameter" => "email"}
             } in errors["errors"] == true
    end

    test "given valid user credentials when encode_and_sign returns error, returns error response",
         %{
           conn: conn
         } do
      stub(Guardian, :encode_and_sign, fn _, _ -> {:error, "error"} end)

      conn =
        post(conn, Routes.api_v1_user_registration_path(conn, :create), %{
          email: "email@gmail.com",
          password: "12345678"
        })

      assert json_response(conn, 500) == %{
               "errors" => [
                 %{
                   "code" => "internal_server_error",
                   "detail" => gettext("Internal server error")
                 }
               ]
             }
    end

    test "given a valid user credentials with an authenticated user, returns access token",
         %{
           conn: conn
         } do
      user = insert(:user)
      email = "new_email@gmail.com"

      conn =
        conn
        |> auth_with_user(user)
        |> post(Routes.api_v1_user_registration_path(conn, :create), %{
          email: email,
          password: "12345678"
        })

      assert %{
               "data" => %{
                 "attributes" => %{
                   "email" => ^email,
                   "token" => _
                 },
                 "id" => _,
                 "relationships" => %{},
                 "type" => "user_registration"
               },
               "included" => []
             } = json_response(conn, 200)
    end

    test "given an invalid user credentials with an authenticated user, returns error response",
         %{
           conn: conn
         } do
      user = insert(:user)

      conn =
        conn
        |> auth_with_user(user)
        |> post(Routes.api_v1_user_registration_path(conn, :create), %{})

      assert json_response(conn, 422) == %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "detail" => gettext("Email or password is missing")
                 }
               ]
             }
    end
  end
end
