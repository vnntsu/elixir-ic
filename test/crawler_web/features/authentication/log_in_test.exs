defmodule CrawlerWeb.Authentication.LogInTest do
  use CrawlerWeb.FeatureCase, async: true

  alias CrawlerWeb.Endpoint

  feature "when authenticated, renders home page", %{session: session} do
    user = insert(:user)
    authenticated_session = log_in_user(session, user)

    assert current_path(authenticated_session) == Routes.home_path(Endpoint, :index)

    authenticated_session
    |> assert_has(Query.text(user.email))
    |> assert_has(Query.text("Log out"))
  end

  feature "when failed to log in, renders log in", %{
    session: session
  } do
    user = build(:user)
    unauthenticated_session = log_in_user(session, user)

    assert current_path(unauthenticated_session) == Routes.user_session_path(Endpoint, :new)

    unauthenticated_session
    |> assert_has(text_field("user[email]"))
    |> assert_has(text_field("user[password]"))
  end
end
