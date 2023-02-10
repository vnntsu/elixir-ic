defmodule CrawlerWeb.Api.V1.KeywordListView do
  use JSONAPI.View, type: "keywords"

  def fields do
    [
      :name,
      :status
    ]
  end
end
