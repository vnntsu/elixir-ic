defmodule CrawlerWeb.Api.V1.KeywordView do
  use JSONAPI.View, type: "keyword"

  def fields do
    [
      :message
    ]
  end
end
