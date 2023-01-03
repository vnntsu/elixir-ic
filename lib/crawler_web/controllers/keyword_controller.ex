defmodule CrawlerWeb.KeywordController do
  use CrawlerWeb, :controller

  alias Crawler.Keyword.Helpers.CSVParser
  alias Crawler.Keyword.Keywords
  alias Crawler.Keyword.Schemas.KeywordCSVFile

  def create(conn, %{"keyword_csv_file" => params}) do
    changeset = %{
      KeywordCSVFile.create_changeset(%KeywordCSVFile{}, params)
      | action: :validate
    }

    case changeset.valid? do
      true ->
        process_uploaded_file(conn, changeset.changes)

      false ->
        show_error_flash_message_and_redirects_to_dasboard(
          conn,
          gettext("The file doesn't look like CSV")
        )
    end
  end

  defp process_uploaded_file(conn, changes) do
    case CSVParser.parse(changes.file.path) do
      {:ok, keyword_list} ->
        {num_keyword, _list} =
          Keywords.create_keyword_list(keyword_list, conn.assigns.current_user.id)

        conn
        |> put_flash(
          :info,
          gettext("%{num_keyword} keywords were uploaded!", num_keyword: num_keyword)
        )
        |> redirect(to: Routes.home_path(conn, :index))

      {:error, reason} ->
        process_validation_error(conn, reason)
    end
  end

  defp process_validation_error(conn, reason) do
    case reason do
      :file_empty ->
        show_error_flash_message_and_redirects_to_dasboard(
          conn,
          gettext("The file is empty")
        )

      :file_length_exceeded ->
        show_error_flash_message_and_redirects_to_dasboard(
          conn,
          gettext("The file is too big, allowed size is up to %{limit} keywords",
            limit: CSVParser.keywords_limit()
          )
        )

      :keyword_length_exceeded ->
        show_error_flash_message_and_redirects_to_dasboard(
          conn,
          gettext("One or more keywords are invalid! Allowed keyword length is %{min}-%{max}",
            min: CSVParser.keyword_min_length(),
            max: CSVParser.keyword_max_length()
          )
        )
    end
  end

  defp show_error_flash_message_and_redirects_to_dasboard(conn, flash_message) do
    conn
    |> put_flash(:error, flash_message)
    |> redirect(to: Routes.home_path(conn, :index))
  end
end
