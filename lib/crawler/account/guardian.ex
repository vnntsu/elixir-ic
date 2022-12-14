defmodule Crawler.Account.Guardian do
  use Guardian, otp_app: :crawler

  alias Crawler.Account.Accounts
  alias Crawler.Account.Schemas.User

  def subject_for_token(%{id: id}, _claims), do: {:ok, to_string(id)}

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user(id) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :resource_not_found}
    end
  end
end
