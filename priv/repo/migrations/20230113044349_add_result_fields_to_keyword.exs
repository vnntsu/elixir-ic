defmodule Crawler.Repo.Migrations.AddResultFieldsToKeyword do
  use Ecto.Migration

  def change do
    alter table(:keywords) do
      add :ad_top_count, :integer, null: true
      add :urls_ad_top, {:array, :text}, null: true
      add :ad_total, :integer, null: true
      add :non_ad_count, :integer, null: true
      add :urls_non_ad, {:array, :text}, null: true
      add :total, :integer, null: true
    end
  end
end
