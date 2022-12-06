defmodule Crawler.AccountsTest do
  use Crawler.DataCase

  alias Crawler.Account.Accounts
  alias Crawler.Account.Schemas.{User, UserToken}

  describe "get_user_by_email_and_password/2" do
    test "given valid email and password, returns the user" do
      %{id: id} = user = insert(:user)

      assert %User{id: ^id} = Accounts.get_user_by_email_and_password(user.email, user.password)
    end

    test "given the email does not exist, returns nil" do
      assert Accounts.get_user_by_email_and_password("unknown@example.com", "hello world!") == nil
    end

    test "given an invalid password, returns nil" do
      user = insert(:user)
      assert Accounts.get_user_by_email_and_password(user.email, "invalid") == nil
    end

    test "given the email and password are nil, raises FunctionClauseError" do
      assert_raise FunctionClauseError, fn ->
        Accounts.get_user_by_email_and_password(nil, nil)
      end
    end
  end

  describe "register_user/1" do
    test "given a valid email, returns a valid changeset" do
      %{email: email} = params = params_for(:user)
      {:ok, user} = Accounts.register_user(params)
      assert user.email == email
      assert is_binary(user.hashed_password)
      assert is_nil(user.password)
    end

    test "given empty email and password, returns an invalid changeset" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{password: ["can't be blank"], email: ["can't be blank"]} = errors_on(changeset)
    end

    test "given invalid email and password, returns an invalid changset" do
      {:error, changeset} = Accounts.register_user(%{email: "not valid", password: "123456"})

      assert "must have the @ sign and no spaces" in errors_on(changeset).email
      assert "should be at least 8 character(s)" in errors_on(changeset).password
    end

    test "given exceeding email and password length, returns an invalid changeset" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_user(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "given a duplicated email, returns an invalid changeset" do
      %{email: email} = insert(:user)
      {:error, lower_changeset} = Accounts.register_user(%{email: email})
      assert "has already been taken" in errors_on(lower_changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, upper_changeset} = Accounts.register_user(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(upper_changeset).email
    end
  end

  describe "change_user_registration/2" do
    test "given valid email and password, returns a valid changeset" do
      %{email: email, password: password} = params = params_for(:user)

      changeset = Accounts.change_user_registration(%User{}, params)

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end

    test "given empty email and password, returns an invalid changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_registration(%User{})
      assert changeset.required == [:password, :email]
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: insert(:user)}
    end

    test "given a user, returns a token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: insert(:user).id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = insert(:user)
      token = Accounts.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "given a valid token, returns a user", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "given an invalid token, returns nil" do
      assert Accounts.get_user_by_session_token("oops") == nil
    end

    test "given an expired token, returns nil", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.get_user_by_session_token(token) == nil
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      user = insert(:user)
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end
end
