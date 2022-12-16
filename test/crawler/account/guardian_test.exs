defmodule Crawler.Account.GuardianTest do
  use Crawler.DataCase, async: true

  alias Crawler.Account.Guardian

  describe "subject_for_token/2" do
    test "given a resource entity, returns resource ID" do
      user = insert(:user)

      assert Guardian.subject_for_token(user, %{}) == {:ok, "#{user.id}"}
    end
  end

  describe "resource_from_claims/1" do
    test "given existing user id, returns correct user" do
      %{id: id} = insert(:user)
      claims = %{"sub" => id}
      {:ok, %{id: claims_user_id}} = Guardian.resource_from_claims(claims)

      assert claims_user_id == id
    end

    test "given non-existing user, returns {:error, :resource_not_found}" do
      claims = %{"sub" => 0}

      assert Guardian.resource_from_claims(claims) == {:error, :resource_not_found}
    end
  end
end
