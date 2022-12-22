defmodule Crawler.Home.KeywordsTest do
  use Crawler.DataCase, async: true

  alias Crawler.Home.Keywords
  alias Crawler.Home.Schemas.Keyword

  describe("list_keywords/1") do
    test "given a valid user id, returns user's keyword list" do
      %{id: user_id} = insert(:user)
      keyword = insert(:keyword, user_id: user_id)

      assert Keywords.list_keywords(user_id) == [keyword]
    end
  end

  describe("create_keyword/1") do
    test "given a valid keyword data, returns a saved keyword" do
      %{id: user_id} = insert(:user)
      keyword_params = %{name: "keyword", user_id: user_id}

      assert {:ok, %Keyword{} = keyword} = Keywords.create_keyword(keyword_params)
      assert keyword.name == "keyword"
    end
  end

  describe("create_keyword_list/2") do
    test "given a valid list of keywords, returns a saved keyword list" do
      %{id: user_id} = insert(:user)
      Keywords.create_keyword_list(["first", "second"], user_id)

      assert length(Keywords.list_keywords(user_id)) == 2
    end

    test "given a list with an existing keyword, modifies status of the keyword to new" do
      %{id: user_id} = insert(:user)
      keyword_params = %{name: "keyword", status: :in_progress, user_id: user_id}
      Keywords.create_keyword(keyword_params)
      Keywords.create_keyword_list(["keyword", "second key"], user_id)

      keyword =
        Enum.find(Keywords.list_keywords(user_id), fn keyword ->
          keyword.name == "keyword"
        end)

      assert keyword.status == :new
    end
  end
end