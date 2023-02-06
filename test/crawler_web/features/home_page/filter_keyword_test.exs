defmodule CrawlerWeb.Features.HomePage.FilterKeywordTest do
  use CrawlerWeb.FeatureCase, async: false

  feature "view list of uploaded keywords table when filtering by a valid keyword", %{
    session: session
  } do
    user = insert(:user)
    insert(:keyword, user_id: user.id, name: "buy phone")
    insert(:keyword, user_id: user.id, name: "buy tv")
    insert(:keyword, user_id: user.id, name: "watch")

    session
    |> log_in_user(user)
    |> visit(Routes.home_path(CrawlerWeb.Endpoint, :index, %{keyword: "buy"}))
    |> assert_has(Query.text(gettext("buy phone")))
    |> assert_has(Query.text(gettext("buy tv")))
    |> refute_has(Query.text(gettext("watch")))
  end

  feature "view an empty list when filtering by an invalid keyword", %{
    session: session
  } do
    user = insert(:user)
    insert(:keyword, user_id: user.id, name: "buy phone")

    session
    |> log_in_user(user)
    |> visit(Routes.home_path(CrawlerWeb.Endpoint, :index, %{keyword: "google"}))
    |> refute_has(Query.text(gettext("buy phone")))
  end
end
