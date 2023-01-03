defmodule CrawlerWeb.KeywordControllerTest do
  use CrawlerWeb.ConnCase, async: true

  alias Crawler.Keyword.Keywords
  alias Crawler.Keyword.Schemas.Keyword

  describe "POST /keyword" do
    test "given valid keyword csv file, creates keyword successfully", %{conn: conn} do
      user = insert(:user)
      uploaded_file = keyword_file_fixture("valid.csv")

      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.keyword_path(conn, :create), %{keyword_csv_file: %{file: uploaded_file}})

      assert get_flash(conn, :info) == "3 #{gettext("keywords were uploaded!")}"

      keywords = Keywords.list_keywords(user.id)

      assert length(keywords) == 3

      assert [%Keyword{name: "one"}, %Keyword{name: "two"}, %Keyword{name: "three"}] = keywords
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
end
