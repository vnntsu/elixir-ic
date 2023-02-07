defmodule Crawler.Keyword.KeywordsTest do
  use Crawler.DataCase, async: true

  alias Crawler.Keyword.Keywords
  alias Crawler.Keyword.Schemas.Keyword
  alias CrawlerWorker.Keyword.CrawlerWorker

  describe "list_user_keywords_by_filter_params/1" do
    test "given a valid user id, returns user's keyword list" do
      %{id: user_id} = insert(:user)
      insert(:keyword, user_id: user_id)

      %{id: expected_user_id} = insert(:user)
      expected_keyword = insert(:keyword, user_id: expected_user_id)

      assert Keywords.list_user_keywords_by_filter_params(expected_user_id) == [expected_keyword]
    end
  end

  describe "list_user_keywords_by_filter_params/2" do
    test "given a valid user id and valid keyword name, returns user's keyword list" do
      %{id: user_id} = insert(:user)
      insert(:keyword, user_id: user_id, name: "keyword")

      %{id: expected_user_id} = insert(:user)
      expected_keyword = insert(:keyword, user_id: expected_user_id, name: "phone")
      insert(:keyword, user_id: expected_user_id, name: "tv")

      assert [%{name: stored_keyword_name}] =
               Keywords.list_user_keywords_by_filter_params(expected_user_id, %{
                 "keyword" => expected_keyword.name
               })

      assert stored_keyword_name == "phone"
    end

    test "given a part of valid keyword, returns user's keyword list" do
      %{id: user_id} = insert(:user)
      insert(:keyword, user_id: user_id, name: "phone")
      insert(:keyword, user_id: user_id, name: "tv")

      %{id: expected_user_id} = insert(:user)
      insert(:keyword, user_id: expected_user_id, name: "phone")
      insert(:keyword, user_id: expected_user_id, name: "tv")

      assert [%{name: stored_keyword_name}] =
               Keywords.list_user_keywords_by_filter_params(expected_user_id, %{
                 "keyword" => "hon"
               })

      assert stored_keyword_name == "phone"
    end

    test "given an invalid keyword, returns empty keyword list" do
      %{id: user_id} = insert(:user)
      insert(:keyword, user_id: user_id, name: "something")

      %{id: expected_user_id} = insert(:user)
      insert(:keyword, user_id: expected_user_id, name: "phone")
      insert(:keyword, user_id: expected_user_id, name: "tv")

      assert Keywords.list_user_keywords_by_filter_params(expected_user_id, %{
               "keyword" => "something"
             }) == []
    end

    test "given a nil keyword, returns keyword list" do
      %{id: user_id} = insert(:user)
      insert(:keyword, user_id: user_id, name: "keyword")

      %{id: expected_user_id} = insert(:user)
      insert(:keyword, user_id: expected_user_id, name: "phone")

      assert [%{name: stored_keyword_name}] =
               Keywords.list_user_keywords_by_filter_params(expected_user_id, %{
                 "keyword" => nil
               })

      assert stored_keyword_name == "phone"
    end

    test "given another filter that is not `keyword`, returns keyword list without filter" do
      %{id: user_id} = insert(:user)
      insert(:keyword, user_id: user_id, name: "phone")

      %{id: expected_user_id} = insert(:user)
      insert(:keyword, user_id: expected_user_id, name: "phone")

      assert [%{name: stored_keyword_name}] =
               Keywords.list_user_keywords_by_filter_params(expected_user_id, %{
                 "another_filter" => "filter_value"
               })

      assert stored_keyword_name == "phone"
    end

    test "given 2 filter params that contains keyword, returns keyword list without filter" do
      %{id: user_id} = insert(:user)
      insert(:keyword, user_id: user_id, name: "phone")

      %{id: expected_user_id} = insert(:user)
      insert(:keyword, user_id: expected_user_id, name: "phone")

      assert [%{name: stored_keyword_name}] =
               Keywords.list_user_keywords_by_filter_params(expected_user_id, %{
                 "keyword" => "phone",
                 "another_filter" => "filter_value"
               })

      assert stored_keyword_name == "phone"
    end
  end

  describe "get_keyword_by_id/1" do
    test "given a valid keyword id, returns stored keyword" do
      %{id: user_id} = insert(:user)
      keyword = insert(:keyword, user_id: user_id, name: "keyword")

      assert stored_keyword = Keywords.get_keyword_by_id(keyword.id)
      assert stored_keyword.id == keyword.id
      assert stored_keyword.name == "keyword"
      assert stored_keyword.user_id == user_id
    end

    test "given an invalid keyword id, returns nil" do
      %{id: user_id} = insert(:user)
      insert(:keyword, user_id: user_id, name: "keyword")

      assert Keywords.get_keyword_by_id(-1) == nil
    end
  end

  describe "get_keyword_by_user_id_and_id!/2" do
    test "given a valid keyword id, returns stored keyword" do
      %{id: user_id} = insert(:user)
      keyword = insert(:keyword, user_id: user_id, name: "keyword")

      assert stored_keyword = Keywords.get_keyword_by_user_id_and_id!(user_id, keyword.id)
      assert stored_keyword.id == keyword.id
      assert stored_keyword.name == "keyword"
      assert stored_keyword.user_id == user_id
    end

    test "given a keyword belongs to another user, raises Ecto.NoResultsError" do
      %{id: user_id} = insert(:user)
      %{id: keyword_id} = insert(:keyword, user_id: user_id, name: "keyword")

      %{id: expected_user_id} = insert(:user)

      assert_raise(Ecto.NoResultsError, fn ->
        Keywords.get_keyword_by_user_id_and_id!(expected_user_id, keyword_id)
      end)
    end
  end

  describe "get_keyword_by_user_id_and_id/2" do
    test "given a valid keyword id, returns stored keyword" do
      %{id: user_id} = insert(:user)
      keyword = insert(:keyword, user_id: user_id, name: "keyword")

      assert stored_keyword = Keywords.get_keyword_by_user_id_and_id(user_id, keyword.id)
      assert stored_keyword.id == keyword.id
      assert stored_keyword.name == "keyword"
      assert stored_keyword.user_id == user_id
    end

    test "given a keyword belongs to another user, returns nil" do
      %{id: user_id} = insert(:user)
      %{id: keyword_id} = insert(:keyword, user_id: user_id, name: "keyword")

      %{id: expected_user_id} = insert(:user)

      assert Keywords.get_keyword_by_user_id_and_id(expected_user_id, keyword_id) == nil
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
      assert Keywords.list_user_keywords_by_filter_params(user_id) == []
    end
  end

  describe "create_keyword_list/2" do
    test "given a valid list of keywords, returns a saved keyword list" do
      %{id: user_id} = insert(:user)

      assert {:ok, keyword_ids} = Keywords.create_keyword_list(["first", "second"], user_id)
      assert length(Keywords.list_user_keywords_by_filter_params(user_id)) == 2

      assert [first_keyword_id, second_keyword_id] = keyword_ids
      assert_enqueued(worker: CrawlerWorker, args: %{keyword_id: first_keyword_id})
      assert_enqueued(worker: CrawlerWorker, args: %{keyword_id: second_keyword_id})
    end

    test "given a keyword list with the wrong user, does not return saved keyword list" do
      %{id: user_id} = insert(:user)
      %{id: expected_user_id} = insert(:user)
      Keywords.create_keyword_list(["first", "second"], user_id)

      assert Keywords.list_user_keywords_by_filter_params(expected_user_id) == []
    end
  end

  describe "mark_as_in_progress/1" do
    test "given a valid keyword, updates keyword's status to in_progress" do
      %{id: user_id} = insert(:user)
      keyword = insert(:keyword, user_id: user_id)

      Keywords.mark_as_in_progress(keyword)
      updated_keyword = Keywords.get_keyword_by_user_id_and_id!(user_id, keyword.id)
      assert updated_keyword.status == :in_progress
    end
  end

  describe "mark_as_completed/1" do
    test "given a valid keyword, updates keyword's status to completed" do
      %{id: user_id} = insert(:user)
      keyword = insert(:keyword, user_id: user_id)

      Keywords.mark_as_completed(keyword, %{html: "html"})
      updated_keyword = Keywords.get_keyword_by_user_id_and_id!(user_id, keyword.id)
      assert updated_keyword.status == :completed
      assert updated_keyword.html == "html"
    end
  end

  describe "mark_as_failed/1" do
    test "given a valid keyword, updates keyword's status to failed" do
      %{id: user_id} = insert(:user)
      keyword = insert(:keyword, user_id: user_id)

      Keywords.mark_as_failed(keyword)
      updated_keyword = Keywords.get_keyword_by_user_id_and_id!(user_id, keyword.id)
      assert updated_keyword.status == :failed
    end
  end
end
