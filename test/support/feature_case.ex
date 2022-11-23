defmodule CrawlerWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.Feature
      use Mimic

      import Crawler.Factory
      import CrawlerWeb.Gettext

      alias Crawler.Repo
      alias CrawlerWeb.Endpoint
      alias CrawlerWeb.Router.Helpers, as: Routes

      @moduletag :feature_test
    end
  end
end
