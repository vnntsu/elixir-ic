defmodule Crawler.Repo.Migrations.CreateKeywords do
  use Ecto.Migration

  def change do
    create table(:keywords) do
      add :name, :string, null: false
      add :status, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:keywords, [:user_id])
    create unique_index(:keywords, [:name, :user_id])
  end
end
