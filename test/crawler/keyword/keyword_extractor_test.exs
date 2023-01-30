defmodule Crawler.Keyword.KeywordExtractorTest do
  use CrawlerWeb.ConnCase, async: true

  alias Crawler.Google.Client, as: GoogleClient
  alias Crawler.Keyword.KeywordExtractor

  describe "parse/1" do
    test "given HTML, returns parsed results" do
      use_cassette "crawl/buy_phone_success" do
        {:ok, html} = GoogleClient.crawl("buy phone")

        assert attrs = KeywordExtractor.parse(html)

        assert attrs.ad_top_count == 11
        assert attrs.ad_total == 9
        assert attrs.non_ad_count == 89
        assert attrs.total == 176
        assert length(attrs.urls_ad_top) == 11
        assert length(attrs.urls_non_ad) == 89
      end
    end
  end
end
