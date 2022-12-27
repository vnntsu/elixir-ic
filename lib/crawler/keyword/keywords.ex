defmodule Crawler.Keyword.Keywords do
  @moduledoc """
  The Keywords context.
  """

  import Ecto.Query, warn: false

  alias Crawler.Keyword.Queries.KeywordQuery
  alias Crawler.Keyword.Schemas.Keyword
  alias Crawler.Repo

  def list_keywords(user_id), do: Repo.all(KeywordQuery.user_keywords_query(user_id))

  def create_keyword(attrs \\ %{}) do
    %Keyword{}
    |> Keyword.changeset(attrs)
    |> Repo.insert()
  end

  def create_keyword_list(keyword_list, user_id) do
    keyword_list
    |> build_keyword_params_list(user_id)
    |> insert_all_keywords()
  end

  defp insert_all_keywords(keyword_params_list) do
    Repo.insert_all(
      Keyword,
      keyword_params_list,
      on_conflict: {:replace_all_except, [:id]},
      conflict_target: [:name, :user_id]
    )
  end

  defp build_keyword_params_list(keyword_list, user_id) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    Enum.map(keyword_list, fn keyword ->
      %{name: keyword, status: :new, user_id: user_id, inserted_at: now, updated_at: now}
    end)
  end
end
