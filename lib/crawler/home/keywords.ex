defmodule Crawler.Home.Keywords do
  @moduledoc """
  The Keywords context.
  """

  import Ecto.Query, warn: false

  alias Crawler.Home.Queries.KeywordQuery
  alias Crawler.Home.Schemas.Keyword
  alias Crawler.Repo

  def list_keywords(user_id), do: Repo.all(KeywordQuery.user_keywords_query(user_id))

  def create_keyword(attrs \\ %{}) do
    %Keyword{}
    |> Keyword.changeset(attrs)
    |> Repo.insert()
  end

  def create_keyword_list(keyword_list, user_id) do
    keyword_params_list = build_keyword_params_list(keyword_list, user_id)

    insert_keywords(keyword_params_list, user_id)
  end

  defp insert_keywords(keyword_params_list, user_id) do
    Enum.each(keyword_params_list, fn keyword_params ->
      keywords = Repo.all(KeywordQuery.user_keywords_query(keyword_params.name, user_id))

      case keywords do
        [] ->
          create_keyword(keyword_params)

        _ ->
          keywords
          |> Enum.at(0)
          |> Keyword.new_changeset()
          |> Repo.update!()
      end
    end)
  end

  defp build_keyword_params_list(keyword_list, user_id) do
    Enum.map(keyword_list, fn keyword ->
      %{name: keyword, user_id: user_id}
    end)
  end
end
