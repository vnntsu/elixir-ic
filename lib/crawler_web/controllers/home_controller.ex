defmodule CrawlerWeb.HomeController do
  use CrawlerWeb, :controller

  alias Crawler.Keyword.Keywords
  alias Crawler.Keyword.Schemas.KeywordCSVFile

  def index(conn, _params) do
    changeset = KeywordCSVFile.create_changeset(%KeywordCSVFile{})
    keywords = Keywords.list_keywords(conn.assigns.current_user.id)

    render(conn, "index.html", keywords: keywords, changeset: changeset)
  end
end
