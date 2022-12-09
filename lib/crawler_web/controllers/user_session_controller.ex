defmodule CrawlerWeb.UserSessionController do
  use CrawlerWeb, :controller

  alias Crawler.Account.Accounts
  alias CrawlerWeb.UserAuth

  def new(conn, _params), do: render(conn, "new.html", error_message: nil)

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end
end
