defmodule CrawlerWeb.Api.V1.KeywordControllerTest do
  use CrawlerWeb.ConnCase, async: true

  alias Crawler.Keyword.Keywords

  describe "GET index/2" do
    test "given a valid user, returns uploaded keywords", %{conn: conn} do
      user = insert(:user)
      insert(:keyword, name: "watch", user_id: user.id)
      insert(:keyword, name: "phone", user_id: user.id)
      insert(:keyword, name: "tv", user_id: user.id)

      expected_user = insert(:user)
      insert(:keyword, name: "phone", user_id: expected_user.id)
      insert(:keyword, name: "tv", user_id: expected_user.id)

      conn =
        conn
        |> auth_with_user(expected_user)
        |> get(Routes.api_v1_keyword_path(conn, :index))

      assert %{
               "data" => [
                 %{
                   "attributes" => %{"name" => "phone", "status" => "new"},
                   "id" => _,
                   "relationships" => %{},
                   "type" => "keywords"
                 },
                 %{
                   "attributes" => %{"name" => "tv", "status" => "new"},
                   "id" => _,
                   "relationships" => %{},
                   "type" => "keywords"
                 }
               ],
               "included" => []
             } = json_response(conn, 200)
    end

    test "given a valid user and valid filtered keyword, returns filtered keywords", %{
      conn: conn
    } do
      user = insert(:user)
      insert(:keyword, name: "watch", user_id: user.id)
      insert(:keyword, name: "phone", user_id: user.id)
      insert(:keyword, name: "tv", user_id: user.id)

      expected_user = insert(:user)
      insert(:keyword, name: "phone", user_id: expected_user.id)
      insert(:keyword, name: "tv", user_id: expected_user.id)

      conn =
        conn
        |> auth_with_user(expected_user)
        |> get(Routes.api_v1_keyword_path(conn, :index, %{keyword: "hon"}))

      assert %{
               "data" => [
                 %{
                   "attributes" => %{"name" => "phone", "status" => "new"},
                   "id" => _,
                   "relationships" => %{},
                   "type" => "keywords"
                 }
               ],
               "included" => []
             } = json_response(conn, 200)
    end

    test "given a valid user and empty filtered keyword, returns uploaded keywords", %{conn: conn} do
      user = insert(:user)
      insert(:keyword, name: "watch", user_id: user.id)

      expected_user = insert(:user)
      insert(:keyword, name: "phone", user_id: expected_user.id)
      insert(:keyword, name: "tv", user_id: expected_user.id)

      conn =
        conn
        |> auth_with_user(expected_user)
        |> get(Routes.api_v1_keyword_path(conn, :index, %{keyword: ""}))

      assert %{
               "data" => [
                 %{
                   "attributes" => %{"name" => "phone", "status" => "new"},
                   "id" => _,
                   "relationships" => %{},
                   "type" => "keywords"
                 },
                 %{
                   "attributes" => %{"name" => "tv", "status" => "new"},
                   "id" => _,
                   "relationships" => %{},
                   "type" => "keywords"
                 }
               ],
               "included" => []
             } = json_response(conn, 200)
    end

    test "given a unauthenticated user, returns unauthorized error", %{conn: conn} do
      conn = get(conn, Routes.api_v1_keyword_path(conn, :index))

      assert %{
               "errors" => [
                 %{
                   "code" => "unauthorized",
                   "detail" => "Unauthorized"
                 }
               ]
             } = json_response(conn, 401)
    end
  end

  describe "GET show/2" do
    test "given a valid keyword id, returns 200 and keyword detail", %{conn: conn} do
      user = insert(:user)

      keyword =
        insert(:keyword,
          name: "phone",
          user_id: user.id,
          status: :completed,
          html: "html",
          ad_total: 5,
          urls_ad_top: [],
          non_ad_count: 10,
          urls_non_ad: [],
          ad_top_count: 10,
          total: 50
        )

      conn =
        conn
        |> auth_with_user(user)
        |> get(Routes.api_v1_keyword_path(conn, :show, keyword.id))

      assert %{
               "data" => %{
                 "attributes" => %{
                   "ad_top_count" => 10,
                   "ad_total" => 5,
                   "name" => "phone",
                   "non_ad_count" => 10,
                   "status" => "completed",
                   "total" => 50,
                   "urls_ad_top" => [],
                   "urls_non_ad" => []
                 },
                 "id" => _,
                 "relationships" => %{},
                 "type" => "keyword"
               },
               "included" => []
             } = json_response(conn, 200)
    end

    test "given an invalid keyword id, returns error not found", %{conn: conn} do
      user = insert(:user)
      %{id: keyword_id} = insert(:keyword, name: "watch", user_id: user.id)

      expected_user = insert(:user)
      insert(:keyword, name: "phone", user_id: expected_user.id)

      detail = gettext("Keyword was not found")

      conn =
        conn
        |> auth_with_user(expected_user)
        |> get(Routes.api_v1_keyword_path(conn, :show, keyword_id))

      assert %{
               "errors" => [
                 %{
                   "code" => "not_found",
                   "detail" => ^detail
                 }
               ]
             } = json_response(conn, 404)
    end
  end

  describe "POST create/2" do
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

      keywords = Keywords.list_user_keywords_by_filter_params(user.id)

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
