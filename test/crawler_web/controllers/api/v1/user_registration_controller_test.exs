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

    test "given existing user credentials, returns error response", %{conn: conn} do
      %{email: email, password: password} = insert(:user)

      conn =
        post(conn, Routes.api_v1_user_registration_path(conn, :create), %{
          email: email,
          password: password
        })

      assert json_response(conn, 422) == %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "detail" => gettext("%{email} has already been taken", email: email)
                 }
               ]
             }
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
  end
end
