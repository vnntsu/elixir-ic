defmodule CrawlerWeb.PageControllerTest do
  use CrawlerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")

    assert html_response(conn, 200) =~ gettext("Crawler")
  end
end
