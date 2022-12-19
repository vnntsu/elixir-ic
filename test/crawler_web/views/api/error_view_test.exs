defmodule CrawlerWeb.Api.ErrorViewTest do
  use CrawlerWeb.ConnCase, async: true

  import Phoenix.View

  # alias Crawler.Account.Accounts
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
  end
end
