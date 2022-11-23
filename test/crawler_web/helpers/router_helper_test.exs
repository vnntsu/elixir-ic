defmodule CrawlerWeb.RouterHelperTest do
  use CrawlerWeb.ConnCase, async: true

  alias CrawlerWeb.RouterHelper

  describe "health_path/0" do
    test "returns the `health_path` from the Application configuration" do
      assert RouterHelper.health_path() == "/_health"
    end
  end
end
