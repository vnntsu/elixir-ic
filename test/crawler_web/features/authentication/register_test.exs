defmodule CrawlerWeb.Authentication.RegisterTest do
  use CrawlerWeb.FeatureCase, async: false

  alias CrawlerWeb.Endpoint

  feature "when registering a new account successfully, renders home page", %{session: session} do
    user = build(:user)
    authenticated_session = register_user(session, user)

    assert current_path(authenticated_session) == Routes.home_path(Endpoint, :index)

    authenticated_session
    |> assert_has(Query.text(user.email))
    |> assert_has(Query.text(gettext("Log out")))
  end
end
