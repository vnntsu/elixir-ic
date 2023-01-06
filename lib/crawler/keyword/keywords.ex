defmodule Crawler.Keyword.Keywords do
  @moduledoc """
  The Keywords context.
  """

  import Ecto.Query, warn: false

  alias Crawler.Keyword.Queries.KeywordQuery
  alias Crawler.Keyword.Schemas.Keyword
  alias Crawler.Repo
  alias CrawlerWorker.Keyword.CrawlerWorker

  def list_keywords(user_id), do: Repo.all(KeywordQuery.user_keywords_query(user_id))

  def get_keyword_by_id(id), do: Repo.get(Keyword, id)

  def create_keyword(attrs \\ %{}) do
    %Keyword{}
    |> Keyword.changeset(attrs)
    |> Repo.insert()
  end

  def create_keyword_list(keyword_list, user_id) do
    create_keyword_fn = fn k ->
      {:ok, %{id: keyword_id}} = create_keyword(k)
      keyword_id
    end

    {:ok, keyword_ids} =
      Repo.transaction(fn ->
        keyword_ids =
          keyword_list
          |> build_keyword_params_list(user_id)
          |> Enum.map(create_keyword_fn)

        enqueue_crawling_job(keyword_ids)

        keyword_ids
      end)

    keyword_ids
  end

  def mark_as_in_progress(keyword) do
    keyword
    |> Keyword.in_progress_changeset()
    |> Repo.update()
  end

  def mark_as_completed(keyword, attrs) do
    keyword
    |> Keyword.completed_changeset(attrs)
    |> Repo.update()
  end

  def mark_as_failed(keyword) do
    keyword
    |> Keyword.failed_changeset()
    |> Repo.update()
  end

  defp build_keyword_params_list(keyword_list, user_id) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    Enum.map(keyword_list, fn keyword ->
      %{name: keyword, user_id: user_id, inserted_at: now, updated_at: now}
    end)
  end

  defp enqueue_crawling_job(keyword_ids) do
    Enum.each(keyword_ids, fn id ->
      %{"keyword_id" => id}
      |> CrawlerWorker.new()
      |> Oban.insert()
    end)
  end
end
