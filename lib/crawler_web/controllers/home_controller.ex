defmodule CrawlerWeb.HomeController do
  use CrawlerWeb, :controller

  alias Crawler.Keyword.Keywords
  alias Crawler.Keyword.Schemas.KeywordCSVFile

  def index(conn, params) do
    changeset = KeywordCSVFile.create_changeset(%KeywordCSVFile{})
    keywords = Keywords.list_user_keywords_by_filter_params(conn.assigns.current_user.id, params)

    render(conn, "index.html", keywords: keywords, changeset: changeset, params: params)
  end
end
