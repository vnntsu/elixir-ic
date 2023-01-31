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

    with {:ok, html} <- GoogleClient.crawl(keyword.name),
         {:ok, attrs} <- KeywordExtractor.parse(html) do
      Keywords.mark_as_completed(keyword, Map.merge(attrs, %{html: html}))
      :ok
    else
      {:error, reason} ->
        Keywords.mark_as_failed(keyword)
        {:error, reason}
    end
  end
end
