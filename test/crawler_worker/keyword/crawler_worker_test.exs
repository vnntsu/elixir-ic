defmodule CrawlerWorker.Keyword.CrawlerWorkerTest do
  use Crawler.DataCase, async: true

  alias Crawler.Keyword.Keywords
  alias CrawlerWorker.Keyword.CrawlerWorker

  describe "perform/1" do
    test "given successfully finished job, returns and stores the HTML result" do
      keyword = insert(:keyword, name: "buy phone")
      args = %{keyword_id: keyword.id}

      use_cassette "crawl/buy_phone_success" do
        assert perform_job(CrawlerWorker, args) == :ok

        stored_keyword = Keywords.get_keyword_by_id(keyword.id)

        assert stored_keyword.status == :completed
        assert is_binary(stored_keyword.html)
        assert stored_keyword.html =~ "buy phone"
        assert stored_keyword.ad_top_count == 11
        assert stored_keyword.ad_total == 9
        assert stored_keyword.non_ad_count == 36
        assert stored_keyword.total == 51
        assert length(stored_keyword.urls_ad_top) == 11
        assert length(stored_keyword.urls_non_ad) == 36
      end
    end

    test "given status_code is 400, set keyword status failed" do
      expect(HTTPoison, :get, fn _, _ -> {:ok, %{status_code: 400}} end)
      keyword = insert(:keyword)
      args = %{keyword_id: keyword.id}

      assert perform_job(CrawlerWorker, args) == {:error, 400}

      stored_keyword = Keywords.get_keyword_by_id(keyword.id)

      assert stored_keyword.status == :failed
      assert stored_keyword.html == nil
    end

    test "given error for keyword searching, set keyword status failed" do
      expect(HTTPoison, :get, fn _, _ -> {:error, %{reason: :error}} end)
      keyword = insert(:keyword)
      args = %{keyword_id: keyword.id}

      assert perform_job(CrawlerWorker, args) == {:error, :error}

      stored_keyword = Keywords.get_keyword_by_id(keyword.id)

      assert stored_keyword.status == :failed
      assert stored_keyword.html == nil
    end
  end
end
