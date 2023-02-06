defmodule CrawlerWeb.Features.HomePage.ViewKeywordListTest do
  use CrawlerWeb.FeatureCase, async: false

  feature "view list of uploaded keywords table for a user", %{session: session} do
    user = insert(:user)
    insert(:keyword, user_id: user.id, name: "buy phone")
    insert(:keyword, user_id: user.id, name: "buy tv")

    session
    |> log_in_user(user)
    |> visit(Routes.home_path(CrawlerWeb.Endpoint, :index))
    |> assert_has(Query.text(gettext("buy phone")))
    |> assert_has(Query.text(gettext("buy tv")))
  end
end
