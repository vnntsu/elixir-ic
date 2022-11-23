defmodule CrawlerWeb.RouterHelper do
  def health_path, do: Application.get_env(:crawler, CrawlerWeb.Endpoint)[:health_path]
end
