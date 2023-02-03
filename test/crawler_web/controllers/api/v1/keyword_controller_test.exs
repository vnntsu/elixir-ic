defmodule CrawlerWeb.Api.V1.KeywordControllerTest do
  use CrawlerWeb.ConnCase, async: true

  alias Crawler.Keyword.Keywords

  describe "POST /keyword/upload" do
    test "given valid keyword csv file, creates keywords and returns 200", %{conn: conn} do
      user = insert(:user)
      uploaded_file = keyword_file_fixture("valid.csv")
      detail = gettext("Keywords were uploaded!")

      conn =
        conn
        |> auth_with_user(user)
        |> post(Routes.api_v1_keyword_path(conn, :create), %{
          keyword_csv_file: uploaded_file
        })

      assert %{
               "data" => %{
                 "attributes" => %{
                   "message" => ^detail
                 },
                 "id" => _,
                 "relationships" => %{},
                 "type" => "keyword"
               },
               "included" => []
             } = json_response(conn, 200)

      keywords = Keywords.list_keywords_by_filter_params(user.id)

      list =
        Enum.map(keywords, fn keyword ->
          keyword.name
        end)

      assert list == ["one", "two", "three"]
    end

    test "given empty file, returns 422 status", %{conn: conn} do
      user = insert(:user)
      uploaded_file = keyword_file_fixture("empty.csv")
      detail = gettext("The file is empty")

      conn =
        conn
        |> auth_with_user(user)
        |> post(Routes.api_v1_keyword_path(conn, :create), %{
          keyword_csv_file: uploaded_file
        })

      assert %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "detail" => ^detail
                 }
               ]
             } = json_response(conn, 422)
    end

    test "given big file, shows validation error", %{conn: conn} do
      user = insert(:user)
      uploaded_file = keyword_file_fixture("big.csv")
      detail = gettext("The file is too big, allowed size is up to 1000 keywords")

      conn =
        conn
        |> auth_with_user(user)
        |> post(Routes.api_v1_keyword_path(conn, :create), %{
          keyword_csv_file: uploaded_file
        })

      assert %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "detail" => ^detail
                 }
               ]
             } = json_response(conn, 422)
    end

    test "given non CSV file, shows validation error", %{conn: conn} do
      user = insert(:user)
      uploaded_file = keyword_file_fixture("non_csv.txt")
      detail = gettext("The file doesn't look like CSV")

      conn =
        conn
        |> auth_with_user(user)
        |> post(Routes.api_v1_keyword_path(conn, :create), %{
          keyword_csv_file: uploaded_file
        })

      assert %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "detail" => ^detail
                 }
               ]
             } = json_response(conn, 422)
    end

    test "given file with invalid keywords, shows validation error", %{conn: conn} do
      user = insert(:user)
      uploaded_file = keyword_file_fixture("non_valid.csv")
      detail = gettext("One or more keywords are invalid! Allowed keyword length is 1-100")

      conn =
        conn
        |> auth_with_user(user)
        |> post(Routes.api_v1_keyword_path(conn, :create), %{
          keyword_csv_file: uploaded_file
        })

      assert %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "detail" => ^detail
                 }
               ]
             } = json_response(conn, 422)
    end

    test "didn't give keyword csv file, shows validation error", %{conn: conn} do
      user = insert(:user)
      detail = gettext("Missing csv file, please add keyword_csv_file to the request's body")

      conn =
        conn
        |> auth_with_user(user)
        |> post(Routes.api_v1_keyword_path(conn, :create))

      assert %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "detail" => ^detail
                 }
               ]
             } = json_response(conn, 422)
    end
  end
end
