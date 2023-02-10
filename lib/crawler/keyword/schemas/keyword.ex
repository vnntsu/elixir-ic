defmodule Crawler.Keyword.Schemas.Keyword do
  use Ecto.Schema

  import Ecto.Changeset

  alias Crawler.Account.Schemas.User

  @keyword_min_length 1
  @keyword_max_length 100

  schema "keywords" do
    field :name, :string
    field :status, Ecto.Enum, values: [:new, :in_progress, :completed, :failed], default: :new
    field :html, :string
    field :ad_top_count, :integer
    field :ad_total, :integer
    field :urls_ad_top, {:array, :string}
    field :non_ad_count, :integer
    field :urls_non_ad, {:array, :string}
    field :total, :integer

    belongs_to :user, User

    timestamps()
  end

  def changeset(keyword, attrs) do
    keyword
    |> cast(attrs, [:name, :status, :user_id, :html])
    |> validate_required([:name, :user_id])
    |> validate_length(:name, min: @keyword_min_length, max: @keyword_max_length)
    |> assoc_constraint(:user)
  end

  def in_progress_changeset(keyword), do: change(keyword, %{status: :in_progress})

  def completed_changeset(keyword, attrs),
    do: change(keyword, Map.merge(attrs, %{status: :completed}))

  def failed_changeset(keyword), do: change(keyword, %{status: :failed})

  def min_length, do: @keyword_min_length
  def max_length, do: @keyword_max_length
end
