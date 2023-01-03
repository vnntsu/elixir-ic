defmodule Crawler.Keyword.Schemas.Keyword do
  use Ecto.Schema

  import Ecto.Changeset

  alias Crawler.Account.Schemas.User

  schema "keywords" do
    field :name, :string
    field :status, Ecto.Enum, values: [:new, :in_progress, :completed, :failed], default: :new

    belongs_to :user, User

    timestamps()
  end

  def changeset(keyword, attrs) do
    keyword
    |> cast(attrs, [:name, :status, :user_id])
    |> validate_required([:name, :user_id])
    |> assoc_constraint(:user)
  end
end
