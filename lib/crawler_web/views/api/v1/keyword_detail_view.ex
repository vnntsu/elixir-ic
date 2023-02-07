defmodule CrawlerWeb.Api.V1.KeywordDetailView do
  use JSONAPI.View, type: "keyword"

  def fields do
    [
      :name,
      :status,
      :ad_top_count,
      :ad_total,
      :urls_ad_top,
      :non_ad_count,
      :urls_non_ad,
      :total
    ]
  end
end
