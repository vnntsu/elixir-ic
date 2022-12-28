defmodule Crawler.Keyword.KeywordsTest do
  use Crawler.DataCase, async: true

  alias Crawler.Keyword.Keywords
  alias Crawler.Keyword.Schemas.Keyword

  describe("list_keywords/1") do
    test "given a valid user id, returns user's keyword list" do
      %{id: user_id} = insert(:user)
      insert(:keyword, user_id: user_id)

      %{id: expected_user_id} = insert(:user)
      expected_keyword = insert(:keyword, user_id: expected_user_id)

      assert Keywords.list_keywords(expected_user_id) == [expected_keyword]
    end
  end

  describe("create_keyword/1") do
    test "given a valid keyword data, creates a keyword" do
      %{id: user_id} = insert(:user)
      keyword_params = %{name: "keyword", user_id: user_id}

      assert {:ok, %Keyword{} = keyword} = Keywords.create_keyword(keyword_params)
      assert keyword.user_id == user_id
      assert keyword.name == "keyword"
    end
  end

  describe("create_keyword_list/2") do
    test "given a valid list of keywords, returns a saved keyword list" do
      %{id: user_id} = insert(:user)
      Keywords.create_keyword_list(["first", "second"], user_id)

      assert length(Keywords.list_keywords(user_id)) == 2
    end
  end
end