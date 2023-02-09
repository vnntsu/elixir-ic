defmodule CrawlerWeb.Api.ErrorViewTest do
  use CrawlerWeb.ConnCase, async: true

  import Phoenix.View

  alias Crawler.Account.Accounts
  alias Crawler.Account.Schemas.User
  alias CrawlerWeb.Api.ErrorView

  describe "render/2" do
    test "given an error, renders error json" do
      assert render(ErrorView, "error.json", %{
               code: :unauthorized,
               detail: "Invalid email or password"
             }) == %{
               errors: [
                 %{
                   code: :unauthorized,
                   detail: "Invalid email or password"
                 }
               ]
             }
    end

    test "given changeset error with multiple errors fields, renders error json" do
      changeset = Accounts.change_user_registration(%User{}, %{email: "email", password: "123456"})
      error = %{code: :unprocessable_entity, changeset: changeset}

      assert render(ErrorView, "error.json", error) ==
               %{
                 errors: [
                   %{
                     code: :unprocessable_entity,
                     detail: "Email must have the @ sign and no spaces",
                     source: %{parameter: :email}
                   },
                   %{
                     code: :unprocessable_entity,
                     detail: "Password should be at least 8 character(s)",
                     source: %{parameter: :password}
                   }
                 ]
               }
    end

    test "given changeset error with a single error, renders error json" do
      changeset =
        Accounts.change_user_registration(%User{}, %{email: "email", password: "12345678"})

      error = %{code: :unprocessable_entity, changeset: changeset}

      assert render(ErrorView, "error.json", error) ==
               %{
                 errors: [
                   %{
                     code: :unprocessable_entity,
                     detail: "Email must have the @ sign and no spaces",
                     source: %{parameter: :email}
                   }
                 ]
               }
    end
  end
end
