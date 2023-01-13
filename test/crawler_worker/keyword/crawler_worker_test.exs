defmodule CrawlerWorker.Keyword.CrawlerWorkerTest do
  use Crawler.DataCase, async: true

  alias Crawler.Keyword.Keywords
  alias CrawlerWorker.Keyword.CrawlerWorker

  describe "perform/1" do
    test "given successfully finished job, returns and stores the HTML result" do
      keyword = insert(:keyword, name: "ios")
      args = %{keyword_id: keyword.id}

      use_cassette "crawl/ios_success" do
        assert perform_job(CrawlerWorker, args) == :ok

        stored_keyword = Keywords.get_keyword_by_id(keyword.id)

        assert stored_keyword.status == :completed
        assert is_binary(stored_keyword.html)
        assert stored_keyword.html =~ "ios"
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
