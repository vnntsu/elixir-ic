defmodule CrawlerWeb.Api.V1.UserSessionControllerTest do
  use CrawlerWeb.ConnCase, async: true

  alias Crawler.Account.Guardian

  describe "POST create/2" do
    test "given valid user credentials, returns access token", %{conn: conn} do
      %{email: email, password: password} = insert(:user)

      conn =
        post(conn, Routes.api_v1_user_session_path(conn, :create), %{
          email: email,
          password: password
        })

      assert %{
               "data" => %{
                 "attributes" => %{
                   "email" => ^email,
                   "token" => _
                 },
                 "id" => _,
                 "relationships" => %{},
                 "type" => "user_session"
               },
               "included" => []
             } = json_response(conn, 200)
    end

    test "given invalid user credentials, returns error response", %{conn: conn} do
      insert(:user)

      conn =
        post(conn, Routes.api_v1_user_session_path(conn, :create), %{
          email: "wrong@gmail.com",
          password: "123"
        })

      assert json_response(conn, 401) == %{
               "errors" => [
                 %{
                   "code" => "unauthorized",
                   "detail" => "Invalid email or password"
                 }
               ]
             }
    end

    test "given invalid request params, returns error response", %{conn: conn} do
      conn =
        post(conn, Routes.api_v1_user_session_path(conn, :create), %{
          not_valid: "not_valid"
        })

      assert json_response(conn, 422) == %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "detail" => "Email or password is missing"
                 }
               ]
             }
    end

    test "given valid user credentials when encode_and_sign returns error, returns error", %{
      conn: conn
    } do
      %{email: email, password: password} = insert(:user)

      stub(Guardian, :encode_and_sign, fn _, _ -> :stub end)

      conn =
        post(conn, Routes.api_v1_user_session_path(conn, :create), %{
          email: email,
          password: password
        })

      assert json_response(conn, 500) == %{
               "errors" => [
                 %{
                   "code" => "internal_server_error",
                   "detail" => "Internal server error"
                 }
               ]
             }
    end
  end
end
