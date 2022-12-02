defmodule Crawler.Accounts.UserFactory do
  alias Crawler.Accounts.Schemas.User
  alias Faker.Blockchain.Bitcoin, as: FakerBitcoin

  defmacro __using__(_opts) do
    quote do
      def user_factory(attrs \\ %{}) do
        password = attrs[:password] || generate_strong_password()

        user = %User{
          email: sequence(:email, &"#{Faker.Internet.user_name()}#{&1}@nimblehq.co"),
          password: password,
          hashed_password: Bcrypt.hash_pwd_salt(password)
        }

        user
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end

      defp generate_strong_password do
        IO.iodata_to_binary([
          FakerBitcoin.address(),
          Enum.random(["!", "@", "#", "$", "%"])
        ])
      end
    end
  end
end
