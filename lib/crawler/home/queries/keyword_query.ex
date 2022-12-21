defmodule Crawler.Home.Queries.KeywordQuery do
  import Ecto.Query

  alias Crawler.Home.Schemas.Keyword

  def user_keywords_query(user_id), do: where(Keyword, [keyword], keyword.user_id == ^user_id)

  def user_keywords_query(name, user_id),
    do: where(Keyword, [keyword], keyword.user_id == ^user_id and keyword.name == ^name)
end
