defmodule CrawlerWeb.Authentication.LogInTest do
  use CrawlerWeb.FeatureCase, async: false

  alias CrawlerWeb.Endpoint

  feature "when authenticated, renders home page", %{session: session} do
    user = insert(:user)
    authenticated_session = log_in_user(session, user)

    assert current_path(authenticated_session) == Routes.home_path(Endpoint, :index)

    authenticated_session
    |> assert_has(Query.text(user.email))
    |> assert_has(Query.text(gettext("Log out")))
  end
end
