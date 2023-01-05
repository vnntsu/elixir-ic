defmodule Crawler.Keyword.Helpers.GoogleCrawler do
  @google_search_url "https://www.google.com/search"
  @headers [
    {
      "User-Agent",
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36"
    },
    {
      "Accept-Language",
      "en-US,en"
    }
  ]

  def crawl(keyword) do
    response =
      keyword
      |> make_crawling_url()
      |> HTTPoison.get(@headers)

    case response do
      {:ok, %{status_code: 200, body: body}} -> {:ok, body}
      {:error, %{reason: reason}} -> {:error, reason}
    end
  end

  defp make_crawling_url(keyword) do
    @google_search_url
    |> URI.parse()
    |> Map.put(:query, URI.encode_query(q: keyword))
    |> URI.to_string()
  end
end
