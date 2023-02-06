defmodule CrawlerWeb.KeywordControllerTest do
  use CrawlerWeb.ConnCase, async: true

  alias Crawler.Keyword.Keywords

  describe "POST /keyword" do
    test "given valid keyword csv file, creates keyword successfully", %{conn: conn} do
      user = insert(:user)
      uploaded_file = keyword_file_fixture("valid.csv")

      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.keyword_path(conn, :create), %{keyword_csv_file: %{file: uploaded_file}})

      assert get_flash(conn, :info) ==
               gettext("%{num_keyword} keywords were uploaded!", num_keyword: 3)

      keywords = Keywords.list_keywords(user.id)

      assert length(keywords) == 3

      created_keyword_names = Enum.map(keywords, fn k -> k.name end)

      assert "one" in created_keyword_names == true
      assert "two" in created_keyword_names == true
      assert "three" in created_keyword_names == true
    end

    test "given empty file, shows validation error", %{conn: conn} do
      user = insert(:user)
      upload_file = keyword_file_fixture("empty.csv")

      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.keyword_path(conn, :create), %{keyword_csv_file: %{file: upload_file}})

      assert get_flash(conn, :info) == nil
      assert get_flash(conn, :error) == gettext("The file is empty")
    end

    test "given big file, shows validation error", %{conn: conn} do
      user = insert(:user)
      upload_file = keyword_file_fixture("big.csv")

      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.keyword_path(conn, :create), %{keyword_csv_file: %{file: upload_file}})

      assert get_flash(conn, :info) == nil

      assert get_flash(conn, :error) ==
               gettext("The file is too big, allowed size is up to 1000 keywords")
    end

    test "given non CSV file, shows validation error", %{conn: conn} do
      user = insert(:user)
      upload_file = keyword_file_fixture("non_csv.txt")

      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.keyword_path(conn, :create), %{keyword_csv_file: %{file: upload_file}})

      assert get_flash(conn, :info) == nil
      assert get_flash(conn, :error) == gettext("The file doesn't look like CSV")
    end

    test "given file with invalid keywords, shows validation error", %{conn: conn} do
      user = insert(:user)
      upload_file = keyword_file_fixture("non_valid.csv")

      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.keyword_path(conn, :create), %{keyword_csv_file: %{file: upload_file}})

      assert get_flash(conn, :info) == nil

      assert get_flash(conn, :error) ==
               gettext("One or more keywords are invalid! Allowed keyword length is 1-100")
    end
  end

  describe "GET show/2" do
    test "given a keyword belongs to a valid user, renders details page", %{conn: conn} do
      user = insert(:user)

      keyword =
        insert(:keyword,
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
        |> log_in_user(user)
        |> get(Routes.keyword_path(conn, :show, keyword))

      response = html_response(conn, 200)

      assert response =~ keyword.name
      assert response =~ "#{gettext("Top Ad Count:")} #{keyword.ad_top_count}"
      assert response =~ "#{gettext("Total Ad Count:")} #{keyword.ad_total}"
      assert response =~ "#{gettext("Non-Ad Count:")} #{keyword.non_ad_count}"
      assert response =~ "#{gettext("Total:")} #{keyword.total}"
    end

    test "given keyword with new status, renders details page with searching status", %{conn: conn} do
      user = insert(:user)

      keyword =
        insert(:keyword,
          user_id: user.id,
          status: :new
        )

      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.keyword_path(conn, :show, keyword))

      response = html_response(conn, 200)

      assert response =~ keyword.name
      assert response =~ gettext("Searching")
    end
  end

  test "given another user keyword, raises Ecto.NoResultsError exception", %{conn: conn} do
    another_user = insert(:user)
    keyword = insert(:keyword, user_id: another_user.id)
    expected_user = insert(:user)

    assert_raise(Ecto.NoResultsError, fn ->
      conn |> log_in_user(expected_user) |> get(Routes.keyword_path(conn, :show, keyword))
    end)
  end
end
