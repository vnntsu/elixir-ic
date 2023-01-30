defmodule CrawlerWorker.Keyword.CrawlerWorker do
  use Oban.Worker,
    queue: :crawler,
    max_attempts: 3,
    tags: ["keyword"],
    unique: [period: 30]

  alias Crawler.Google.Client, as: GoogleClient
  alias Crawler.Keyword.{KeywordExtractor, Keywords}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"keyword_id" => keyword_id}}) do
    keyword = Keywords.get_keyword_by_id(keyword_id)
    Keywords.mark_as_in_progress(keyword)

    case GoogleClient.crawl(keyword.name) do
      {:ok, html} ->
        attrs = KeywordExtractor.parse(html)
        Keywords.mark_as_completed(keyword, Map.merge(attrs, %{html: html}))
        :ok

      {:error, reason} ->
        Keywords.mark_as_failed(keyword)
        {:error, reason}
    end
  end
end
