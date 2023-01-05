defmodule Crawler.Keyword.Schemas.Keyword do
  use Ecto.Schema

  import Ecto.Changeset

  alias Crawler.Account.Schemas.User

  schema "keywords" do
    field :name, :string
    field :status, Ecto.Enum, values: [:new, :in_progress, :completed, :failed], default: :new
    field :html, :string

    belongs_to :user, User

    timestamps()
  end

  def changeset(keyword, attrs) do
    keyword
    |> cast(attrs, [:name, :status, :user_id, :html])
    |> validate_required([:name, :user_id])
    |> assoc_constraint(:user)
  end

  def in_progress_changeset(keyword), do: change(keyword, %{status: :in_progress})

  def completed_changeset(keyword, attrs),
    do: change(keyword, Map.merge(attrs, %{status: :completed}))

  def failed_changeset(keyword), do: change(keyword, %{status: :failed})
end
