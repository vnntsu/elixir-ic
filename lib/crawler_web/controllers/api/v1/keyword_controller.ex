defmodule CrawlerWeb.Api.V1.KeywordController do
  use CrawlerWeb, :controller

  alias Crawler.Keyword.Helpers.CSVParser
  alias Crawler.Keyword.Keywords
  alias Crawler.Keyword.Schemas.{Keyword, KeywordCSVFile}
  alias CrawlerWeb.Api.ErrorView
  alias CrawlerWeb.Api.V1.KeywordListView

  def index(conn, params) do
    keywords = Keywords.list_user_keywords_by_filter_params(conn.assigns.current_user.id, params)

    conn
    |> put_view(KeywordListView)
    |> render("show.json", %{data: keywords})
  end

  def create(conn, %{"keyword_csv_file" => params}) do
    changeset = %{
      KeywordCSVFile.create_changeset(%KeywordCSVFile{}, %{file: params})
      | action: :validate
    }

    case changeset.valid? do
      true ->
        parse_uploaded_file(conn, changeset.changes)

      false ->
        render_error_message(
          conn,
          gettext("The file doesn't look like CSV")
        )
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ErrorView)
    |> render("error.json", %{
      code: :unprocessable_entity,
      detail: gettext("Missing csv file, please add keyword_csv_file to the request's body")
    })
  end

  defp parse_uploaded_file(conn, changes) do
    with {:ok, keyword_list} <- CSVParser.parse(changes.file.path),
         {:ok, _keyword_ids} <-
           Keywords.create_keyword_list(keyword_list, conn.assigns.current_user.id) do
      render(conn, "show.json", %{
        data: %{
          id: :os.system_time(:millisecond),
          message: gettext("Keywords were uploaded!")
        }
      })
    else
      {:error, reason} ->
        process_validation_error(conn, reason)
    end
  end

  defp process_validation_error(conn, reason) do
    case reason do
      :file_empty ->
        render_error_message(
          conn,
          gettext("The file is empty")
        )

      :file_length_exceeded ->
        render_error_message(
          conn,
          gettext("The file is too big, allowed size is up to %{limit} keywords",
            limit: CSVParser.keywords_limit()
          )
        )

      :keyword_length_exceeded ->
        render_error_message(
          conn,
          gettext("One or more keywords are invalid! Allowed keyword length is %{min}-%{max}",
            min: Keyword.min_length(),
            max: Keyword.max_length()
          )
        )
    end
  end

  defp render_error_message(conn, message) do
    conn
    |> put_view(ErrorView)
    |> put_status(:unprocessable_entity)
    |> render("error.json", %{code: :unprocessable_entity, detail: message})
  end
end
