defmodule Crawler.Keyword.KeywordExtractor do
  @selectors %{
    ad_top: "#tads div.top-pla-group-inner div.mnr-c",
    ad_top_count: "div.pla-unit-container",
    urls_ad_top: "a[data-impdclcc]",
    non_ad_count: "#res div.v7W49e",
    urls_non_ad: ".yuRUbf > a",
    total: "a[href]"
  }

  def parse(html) do
    {_, document} = Floki.parse_document(html)
    ad_top_document = Floki.find(document, @selectors.ad_top)

    %{
      ad_top_count: ad_top_count(ad_top_document),
      urls_ad_top: urls_ad_top(ad_top_document),
      ad_total: ad_total(document),
      non_ad_count: non_ad_count(document),
      urls_non_ad: urls_non_ad(document),
      total: total(document)
    }
  end

  defp ad_top_count(document) do
    document
    |> urls_ad_top()
    |> Enum.count()
  end

  defp urls_ad_top(document) do
    document
    |> Floki.find(@selectors.urls_ad_top)
    |> Floki.attribute("a", "href")
    |> Enum.uniq()
  end

  defp ad_total(document) do
    document
    |> Floki.find(@selectors.ad_top_count)
    |> Enum.count()
  end

  defp non_ad_count(document) do
    document
    |> urls_non_ad()
    |> Enum.count()
  end

  defp urls_non_ad(document) do
    document
    |> Floki.find(@selectors.non_ad_count)
    |> Floki.attribute("a", "href")
  end

  defp total(document) do
    document
    |> Floki.find(@selectors.total)
    |> Enum.count()
  end
end
