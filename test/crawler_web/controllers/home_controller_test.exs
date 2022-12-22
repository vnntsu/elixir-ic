defmodule CrawlerWeb.HomeControllerTest do
  use CrawlerWeb.ConnCase, async: true

  describe "GET /home" do
    test "given an authenticated user, renders the home page", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.home_path(conn, :index))

      assert conn.assigns.current_user.id == user.id

      response = html_response(conn, 200)
      assert response =~ gettext("Home")
      assert response =~ gettext("Please choose a CSV file:")
    end

    test "give an unauthenticated user, renders the log in page", %{conn: conn} do
      conn =
        conn
        |> get(Routes.home_path(conn, :index))
        |> get(Routes.user_session_path(conn, :new))

      assert html_response(conn, 200) =~ "#{gettext("Log in")}</a>"
    end
  end

  describe "POST /home" do
    test "given valid keyword csv file, creates keyword successfully", %{conn: conn} do
      user = insert(:user)
      uploaded_file = keyword_file_fixture("valid.csv")

      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.home_path(conn, :create), %{keyword_csv_file: %{file: uploaded_file}})

      assert get_flash(conn, :info) == gettext("Keywords were uploaded!")
    end

    test "given empty file, shows validation error", %{conn: conn} do
      user = insert(:user)
      upload_file = keyword_file_fixture("empty.csv")

      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.home_path(conn, :create), %{keyword_csv_file: %{file: upload_file}})

      assert get_flash(conn, :info) == nil
      assert get_flash(conn, :error) == "The file is empty."
    end

    test "given big file, shows validation error", %{conn: conn} do
      user = insert(:user)
      upload_file = keyword_file_fixture("big.csv")

      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.home_path(conn, :create), %{keyword_csv_file: %{file: upload_file}})

      assert get_flash(conn, :info) == nil
      assert get_flash(conn, :error) == "The file is too big, allowed size is up to 1000 keywords."
    end

    test "given non CSV file, shows validation error", %{conn: conn} do
      user = insert(:user)
      upload_file = keyword_file_fixture("non_csv.txt")

      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.home_path(conn, :create), %{keyword_csv_file: %{file: upload_file}})

      assert get_flash(conn, :info) == nil
      assert get_flash(conn, :error) == "The file doesn't look like CSV."
    end

    test "given file with invalid keywords, shows validation error", %{conn: conn} do
      user = insert(:user)
      upload_file = keyword_file_fixture("non_valid.csv")

      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.home_path(conn, :create), %{keyword_csv_file: %{file: upload_file}})

      assert get_flash(conn, :info) == nil

      assert get_flash(conn, :error) ==
               "One or more keywords are invalid! Allowed keyword length is 1-100"
    end
  end
end
