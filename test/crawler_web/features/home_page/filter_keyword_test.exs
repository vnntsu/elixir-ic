defmodule CrawlerWeb.Features.HomePage.FilterKeywordTest do
  use CrawlerWeb.FeatureCase, async: false

  alias Wallaby.Query

  feature "view list of uploaded keywords table when filtering by a valid keyword", %{
    session: session
  } do
    user = insert(:user)
    insert(:keyword, user_id: user.id, name: "buy phone")
    insert(:keyword, user_id: user.id, name: "buy tv")
    insert(:keyword, user_id: user.id, name: "watch")

    session
    |> log_in_user(user)
    |> visit(Routes.home_path(CrawlerWeb.Endpoint, :index))
    |> fill_in(Query.text_field("keyword"), with: "buy")
    |> click(Query.button("Submit"))
    |> assert_has(Query.text_field("keyword", with: "buy"))
    |> assert_has(Query.text("buy phone"))
    |> assert_has(Query.text("buy tv"))
    |> refute_has(Query.text("watch"))
  end

  feature "view an empty list when filtering by an invalid keyword", %{
    session: session
  } do
    user = insert(:user)
    insert(:keyword, user_id: user.id, name: "buy phone")

    session
    |> log_in_user(user)
    |> visit(Routes.home_path(CrawlerWeb.Endpoint, :index))
    |> fill_in(Query.text_field("keyword"), with: "google")
    |> click(Query.button("Submit"))
    |> assert_has(Query.text(gettext("No keywords found, try with another keyword")))
    |> refute_has(Query.text("buy phone"))
  end
end
