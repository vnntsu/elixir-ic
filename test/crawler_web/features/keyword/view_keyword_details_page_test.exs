defmodule CrawlerWeb.Features.Keyword.ViewKeywordDetailsPageTest do
  use CrawlerWeb.FeatureCase, async: false

  feature "view keyword details page", %{session: session} do
    user = insert(:user)
    keyword = insert(:keyword, user_id: user.id, name: "buy phone")

    session
    |> log_in_user(user)
    |> visit(Routes.keyword_path(CrawlerWeb.Endpoint, :show, keyword))
    |> assert_has(Query.text(gettext("buy phone")))
  end

  feature "redirects to home page with error message if keyword is not found", %{
    session: session
  } do
    user = insert(:user)
    keyword = insert(:keyword, user_id: user.id)
    expected_user = insert(:user)

    session
    |> log_in_user(expected_user)
    |> visit(Routes.keyword_path(CrawlerWeb.Endpoint, :show, keyword))
    |> assert_has(Query.text(gettext("Not Found")))
  end
end
