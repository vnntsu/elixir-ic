defmodule Crawler.Keyword.Queries.KeywordQuery do
  import Ecto.Query

  alias Crawler.Keyword.Schemas.Keyword

  def user_keywords_query(user_id) do
    Keyword
    |> where([k], k.user_id == ^user_id)
    |> order_by(desc: :inserted_at)
  end
end
