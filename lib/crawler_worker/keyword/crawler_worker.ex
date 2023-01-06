defmodule CrawlerWorker.Keyword.CrawlerWorker do
  use Oban.Worker,
    queue: :crawler,
    max_attempts: 3,
    tags: ["keyword"],
    unique: [period: 30]

  alias Crawler.Keyword.Keywords
  alias Crawler.Keyword.Helpers.GoogleCrawler

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"keyword_id" => keyword_id}}) do
    keyword = Keywords.get_keyword_by_id(keyword_id)
    Keywords.mark_as_in_progress(keyword)

    case GoogleCrawler.crawl(keyword.name) do
      {:ok, html} ->
        Keywords.mark_as_completed(keyword, %{html: html})
        :ok

      {:error, reason} ->
        Keywords.mark_as_failed(keyword)
        {:error, reason}
    end
  end
end
