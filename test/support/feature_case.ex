defmodule CrawlerWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.Feature
      use Mimic

      import Crawler.Factory
      import CrawlerWeb.Gettext
      import Wallaby.Query

      alias Crawler.Repo
      alias CrawlerWeb.Endpoint
      alias CrawlerWeb.Router.Helpers, as: Routes

      @moduletag :feature_test

      def register_user(session, user \\ build(:user)) do
        session
        |> visit(Routes.user_registration_path(Endpoint, :new))
        |> fill_in_registration_form(user)
      end

      def log_in_user(session, user \\ build(:user)) do
        session
        |> visit(Routes.user_session_path(Endpoint, :new))
        |> fill_in_log_in_form(user)
      end

      defp fill_in_log_in_form(session, user) do
        session
        |> fill_in(text_field("user[email]"), with: user.email)
        |> fill_in(text_field("user[password]"), with: user.password)
        |> click(button("Log in"))
      end

      defp fill_in_registration_form(session, user) do
        session
        |> fill_in(text_field("user[email]"), with: user.email)
        |> fill_in(text_field("user[password]"), with: user.password)
        |> click(button(gettext("Register")))
      end
    end
  end
end
