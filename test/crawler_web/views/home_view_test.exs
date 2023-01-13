defmodule CrawlerWeb.HomeViewTest do
  use CrawlerWeb.ConnCase, async: true

  alias CrawlerWeb.HomeView

  describe "get_column_status/1" do
    test "given status new, returns text-info",
      do: assert(HomeView.get_column_status(:new) == "text-info")

    test "given status in_progress, returns text-warning",
      do: assert(HomeView.get_column_status(:in_progress) == "text-warning")

    test "given status completed, returns text-success",
      do: assert(HomeView.get_column_status(:completed) == "text-success")

    test "given status failed, returns text-danger",
      do: assert(HomeView.get_column_status(:failed) == "text-danger")

    test "given status undefined, returns text-muted",
      do: assert(HomeView.get_column_status(:undefined) == "text-muted")
  end

  describe "get_status/1" do
    test "given status new, returns New",
      do: assert(HomeView.get_status(:new) == gettext("New"))

    test "given status in_progress, returns Crawling",
      do: assert(HomeView.get_status(:in_progress) == gettext("Crawling"))

    test "given status completed, returns Completed",
      do: assert(HomeView.get_status(:completed) == gettext("Completed"))

    test "given status failed, returns Failed",
      do: assert(HomeView.get_status(:failed) == gettext("Failed"))

    test "given status undefined, returns Undefined",
      do: assert(HomeView.get_status(:undefined) == gettext("Undefined"))
  end
end
