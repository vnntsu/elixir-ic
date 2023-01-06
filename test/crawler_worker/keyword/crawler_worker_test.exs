defmodule CrawlerWorker.Keyword.CrawlerWorkerTest do
  use Crawler.DataCase, async: true

  alias Crawler.Keyword.Keywords
  alias CrawlerWorker.Keyword.CrawlerWorker

  describe "perform/1" do
    test "given a keyword, returns and stores the HTML result" do
      use_cassette "crawl/ios_success" do
        keyword = insert(:keyword, name: "ios")

        %{keyword_id: keyword.id}
        |> CrawlerWorker.new()
        |> Oban.insert()

        stored_keyword = Keywords.get_keyword_by_id(keyword.id)

        assert stored_keyword.status == :completed
        assert is_binary(stored_keyword.html)
      end
    end

    test "given error for keyword searching, set keyword status failed" do
      expect(HTTPoison, :get, fn _, _ -> {:error, %{reason: :error}} end)

      keyword = insert(:keyword)

      %{keyword_id: keyword.id}
      |> CrawlerWorker.new()
      |> Oban.insert()

      stored_keyword = Keywords.get_keyword_by_id(keyword.id)

      assert stored_keyword.status == :failed
    end
  end
end
