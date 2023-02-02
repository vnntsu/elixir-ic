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

  def get_keyword_by_user_id_and_id(user_id, id), do: Repo.get_by(Keyword, id: id, user_id: user_id)

  def create_keyword(attrs \\ %{}) do
    %Keyword{}
    |> Keyword.changeset(attrs)
    |> Repo.insert()
  end

  def create_keyword_list(keyword_list, user_id) do
    create_keyword_fn = fn k ->
      case create_keyword(k) do
        {:ok, %{id: keyword_id}} -> keyword_id
        # throw  error if a keyword is invalid
        {:error, changeset} -> throw({:error, changeset})
      end
    end

    Repo.transaction(fn ->
      try do
        keyword_ids =
          keyword_list
          |> build_keyword_params_list(user_id)
          |> Enum.map(create_keyword_fn)

        enqueue_crawling_job(keyword_ids)

        keyword_ids
      catch
        # TODO: handle to show error
        {:error, _changeset} -> Repo.rollback(:keyword_length_exceeded)
      end
    end)
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
    Enum.map(keyword_list, fn keyword ->
      %{name: keyword, user_id: user_id}
    end)
  end

  defp enqueue_crawling_job(keyword_ids) do
    keyword_ids
    |> Enum.map(fn id -> CrawlerWorker.new(%{"keyword_id" => id}) end)
    |> Oban.insert_all()
  end
end
