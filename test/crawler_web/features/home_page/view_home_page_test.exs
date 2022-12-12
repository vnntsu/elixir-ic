defmodule CrawlerWeb.HomePage.ViewHomePageTest do
  use CrawlerWeb.FeatureCase, async: false

  feature "view home page", %{session: session} do
    visit(session, Routes.page_path(CrawlerWeb.Endpoint, :index))

    assert_has(session, Query.text("Crawler - Su T.'s Elixir IC"))
  end
end
