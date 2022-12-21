defmodule Crawler.Home.Schemas.Keyword do
  use Ecto.Schema

  import Ecto.Changeset

  schema "keywords" do
    field :name, :string
    field :status, Ecto.Enum, values: [:new, :in_progress, :completed, :failed], default: :new

    belongs_to :user, Crawler.Account.Schemas.User

    timestamps()
  end

  @doc false
  def changeset(keyword, attrs) do
    keyword
    |> cast(attrs, [:name, :status, :user_id])
    |> validate_required([:name, :user_id])
    |> unique_constraint(:name, name: :keywords_title_user_id_index)
    |> assoc_constraint(:user)
  end

  def new_changeset(keyword), do: change(keyword, status: :new)
end
