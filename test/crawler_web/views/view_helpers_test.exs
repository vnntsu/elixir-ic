defmodule CrawlerWeb.ViewHelpersTest do
  use CrawlerWeb.ConnCase, async: true

  alias CrawlerWeb.ViewHelpers

  describe "get_column_status/1" do
    test "given status new, returns text-info",
      do: assert(ViewHelpers.get_column_status(:new) == "text-info")

    test "given status in_progress, returns text-warning",
      do: assert(ViewHelpers.get_column_status(:in_progress) == "text-warning")

    test "given status completed, returns text-success",
      do: assert(ViewHelpers.get_column_status(:completed) == "text-success")

    test "given status failed, returns text-danger",
      do: assert(ViewHelpers.get_column_status(:failed) == "text-danger")

    test "given status undefined, returns text-muted",
      do: assert(ViewHelpers.get_column_status(:undefined) == "text-muted")
  end

  describe "get_status/1" do
    test "given status new, returns New",
      do: assert(ViewHelpers.get_status(:new) == gettext("New"))

    test "given status in_progress, returns Crawling",
      do: assert(ViewHelpers.get_status(:in_progress) == gettext("Crawling"))

    test "given status completed, returns Completed",
      do: assert(ViewHelpers.get_status(:completed) == gettext("Completed"))

    test "given status failed, returns Failed",
      do: assert(ViewHelpers.get_status(:failed) == gettext("Failed"))

    test "given status undefined, returns Undefined",
      do: assert(ViewHelpers.get_status(:undefined) == gettext("Undefined"))
  end
end
