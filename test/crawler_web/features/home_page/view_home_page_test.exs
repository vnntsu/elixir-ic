defmodule CrawlerWeb.HomePage.ViewHomePageTest do
  use CrawlerWeb.FeatureCase, async: false

  describe "a unauthenticated user" do
    feature "view home page", %{session: session} do
      visit(session, Routes.page_path(CrawlerWeb.Endpoint, :index))

      assert_has(session, Query.text("Crawler - Su T.'s Elixir IC"))
    end
  end

  describe "a authenticated user when having keywords" do
    feature "view home page", %{session: session} do
      user = insert(:user)
      insert(:keyword, user_id: user.id, name: "buy phone")

      session
      |> log_in_user(user)
      |> visit(Routes.home_path(CrawlerWeb.Endpoint, :index))
      |> assert_has(Query.text(gettext("Please choose a CSV file:")))
      |> assert_has(Query.text(gettext("Submit")))
      |> assert_has(Query.text(gettext("buy phone")))
    end
  end

  describe "a authenticated user when no keywords" do
    feature "view home page", %{session: session} do
      user = insert(:user)

      session
      |> log_in_user(user)
      |> visit(Routes.home_path(CrawlerWeb.Endpoint, :index))
      |> assert_has(Query.text(gettext("Please choose a CSV file:")))
      |> assert_has(Query.text(gettext("Submit")))
      |> assert_has(Query.text(gettext("You don't have keywords yet, please upload a CSV file.")))
    end
  end
end
