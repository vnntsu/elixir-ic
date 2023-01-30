defmodule Crawler.Keyword.KeywordExtractorTest do
  use CrawlerWeb.ConnCase, async: true

  alias Crawler.Google.Client, as: GoogleClient
  alias Crawler.Keyword.KeywordExtractor

  describe "parse/1" do
    test "given HTML, returns parsed results" do
      use_cassette "crawl/iphone_success" do
        {:ok, html} = GoogleClient.crawl("iphone")

        assert attrs = KeywordExtractor.parse(html)

        assert attrs.ad_top_count == 0
        assert attrs.ad_total == 9
        assert attrs.non_ad_count == 108
        assert attrs.total == 207
        assert attrs.urls_ad_top == []
        assert length(attrs.urls_non_ad) == 108
      end
    end
  end
end
