defmodule Crawler.Keyword.Queries.KeywordQuery do
  import Ecto.Query

  alias Crawler.Keyword.Schemas.Keyword

  def user_keywords_query(user_id),
    do:
      Keyword
      |> where([k], k.user_id == ^user_id)
      |> order_by(desc: :inserted_at)

  def user_keywords_query(name, user_id),
    do: where(Keyword, [k], k.user_id == ^user_id and k.name == ^name)
end
