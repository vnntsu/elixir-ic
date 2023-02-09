defmodule CrawlerWeb.Api.V1.UserRegistrationController do
  use CrawlerWeb, :controller

  alias Crawler.Account.{Accounts, Guardian}
  alias Crawler.Account.Schemas.User
  alias CrawlerWeb.Api.ErrorView

  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.register_user(%{"email" => email, "password" => password}) do
      {:ok, user} ->
        process_user_encode_and_sign(conn, user)

      {:error, changeset} ->
        # Enum.each(changeset.errors, fn error ->
        #   case error do
        #     {:email, reason} -> IO.inspect(reason)
        #     {:password, reason} -> IO.inspect(reason)
        #   end

        #   # IO.inspect(error)
        # end)

        conn
        |> put_view(ErrorView)
        |> put_status(:unprocessable_entity)
        |> render("error.json", %{
          code: :unprocessable_entity,
          changeset: changeset
        })
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ErrorView)
    |> render("error.json", %{
      code: :unprocessable_entity,
      detail: gettext("Email or password is missing")
    })
  end

  defp process_user_encode_and_sign(conn, %User{} = user) do
    case Guardian.encode_and_sign(user, %{}) do
      {:ok, token, _claims} ->
        render(conn, "show.json", %{
          data: %{id: :os.system_time(:millisecond), token: token, email: user.email}
        })

      {:error, _reason} ->
        conn
        |> put_view(ErrorView)
        |> put_status(:internal_server_error)
        |> render("error.json", %{
          code: :internal_server_error,
          detail: gettext("Internal server error")
        })
    end
  end
end
