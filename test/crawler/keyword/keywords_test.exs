defmodule Crawler.Keyword.KeywordsTest do
  use Crawler.DataCase, async: true

  alias Crawler.Keyword.Keywords
  alias Crawler.Keyword.Schemas.Keyword
  alias CrawlerWorker.Keyword.CrawlerWorker

  describe "list_keywords/1" do
    test "given a valid user id, returns user's keyword list" do
      %{id: user_id} = insert(:user)
      insert(:keyword, user_id: user_id)

      %{id: expected_user_id} = insert(:user)
      expected_keyword = insert(:keyword, user_id: expected_user_id)

      assert Keywords.list_keywords(expected_user_id) == [expected_keyword]
    end
  end

  describe "create_keyword/1" do
    test "given a valid keyword data, creates a keyword" do
      %{id: user_id} = insert(:user)
      keyword_params = %{name: "keyword", user_id: user_id}

      assert {:ok, %Keyword{} = keyword} = Keywords.create_keyword(keyword_params)
      assert keyword.user_id == user_id
      assert keyword.name == "keyword"
    end

    test "given an invalid keyword data, returns error" do
      keyword_params = %{name: ""}

      assert {:error, _reason} = Keywords.create_keyword(keyword_params)
    end

    test "given the list of keywords with invalid keyword, does not save keywords" do
      %{id: user_id} = insert(:user)

      assert {:error, _reason} = Keywords.create_keyword_list(["one", ""], user_id)
      assert Keywords.list_keywords(user_id) == []
    end
  end

  describe "create_keyword_list/2" do
    test "given a valid list of keywords, returns a saved keyword list" do
      %{id: user_id} = insert(:user)

      assert {:ok, keyword_ids} = Keywords.create_keyword_list(["first", "second"], user_id)
      assert length(Keywords.list_keywords(user_id)) == 2

      assert [first_keyword_id, second_keyword_id] = keyword_ids
      assert_enqueued(worker: CrawlerWorker, args: %{keyword_id: first_keyword_id})
      assert_enqueued(worker: CrawlerWorker, args: %{keyword_id: second_keyword_id})
    end

    test "given a keyword list with the wrong user, does not return saved keyword list" do
      %{id: user_id} = insert(:user)
      %{id: expected_user_id} = insert(:user)
      Keywords.create_keyword_list(["first", "second"], user_id)

      assert Keywords.list_keywords(expected_user_id) == []
    end
  end

  describe "mark_as_in_progress/1" do
    test "given a valid keyword, updates keyword's status to in_progress" do
      %{id: user_id} = insert(:user)
      keyword = insert(:keyword, user_id: user_id)

      Keywords.mark_as_in_progress(keyword)
      updated_keyword = Keywords.get_keyword_by_id(keyword.id)
      assert updated_keyword.status == :in_progress
    end
  end

  describe "mark_as_completed/1" do
    test "given a valid keyword, updates keyword's status to completed" do
      %{id: user_id} = insert(:user)
      keyword = insert(:keyword, user_id: user_id)

      Keywords.mark_as_completed(keyword, %{html: "html"})
      updated_keyword = Keywords.get_keyword_by_id(keyword.id)
      assert updated_keyword.status == :completed
      assert updated_keyword.html == "html"
    end
  end

  describe "mark_as_failed/1" do
    test "given a valid keyword, updates keyword's status to failed" do
      %{id: user_id} = insert(:user)
      keyword = insert(:keyword, user_id: user_id)

      Keywords.mark_as_failed(keyword)
      updated_keyword = Keywords.get_keyword_by_id(keyword.id)
      assert updated_keyword.status == :failed
    end
  end
end
