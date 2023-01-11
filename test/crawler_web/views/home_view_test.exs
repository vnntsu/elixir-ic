defmodule CrawlerWeb.HomeViewTest do
  use CrawlerWeb.ConnCase, async: true

  alias CrawlerWeb.HomeView

  describe "get_column_status/2" do
    test "given status new, returns text-info",
      do: assert(HomeView.get_column_status(:new) == "text-info")

    test "given status in_progress, returns text-info",
      do: assert(HomeView.get_column_status(:in_progress) == "text-warning")

    test "given status completed, returns text-info",
      do: assert(HomeView.get_column_status(:completed) == "text-success")

    test "given status failed, returns text-info",
      do: assert(HomeView.get_column_status(:failed) == "text-danger")

    test "given status undefined, returns text-info",
      do: assert(HomeView.get_column_status(:undefined) == "text-muted")
  end

  describe "get_status/2" do
    test "given status new, returns text-info",
      do: assert(HomeView.get_status(:new) == "New")

    test "given status in_progress, returns text-info",
      do: assert(HomeView.get_status(:in_progress) == "Crawling")

    test "given status completed, returns text-info",
      do: assert(HomeView.get_status(:completed) == "Completed")

    test "given status failed, returns text-info",
      do: assert(HomeView.get_status(:failed) == "Failed")

    test "given status undefined, returns text-info",
      do: assert(HomeView.get_status(:undefined) == "Undefined")
  end
end
