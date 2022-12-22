defmodule Crawler.Keyword.Schemas.Keyword do
  use Ecto.Schema

  import Ecto.Changeset

  schema "keywords" do
    field :name, :string
    field :status, Ecto.Enum, values: [:new, :in_progress, :completed, :failed], default: :new

    belongs_to :user, Crawler.Account.Schemas.User

    timestamps()
  end

  def new_status_changeset(keyword), do: change(keyword, status: :new)

  def changeset(keyword, attrs) do
    keyword
    |> cast(attrs, [:name, :status, :user_id])
    |> validate_required([:name, :user_id])
    |> unique_constraint(:name, name: :keywords_title_user_id_index)
    |> assoc_constraint(:user)
  end
end
