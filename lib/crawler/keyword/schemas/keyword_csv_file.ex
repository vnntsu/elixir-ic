defmodule Crawler.Keyword.Schemas.KeywordCSVFile do
  use Ecto.Schema

  import CrawlerWeb.Gettext
  import Ecto.Changeset

  embedded_schema do
    field :file, :map
  end

  def create_changeset(keyword_file, attrs \\ %{}) do
    keyword_file
    |> cast(attrs, [:file])
    |> validate_required([:file])
    |> validate_file_type()
  end

  defp validate_file_type(changeset) do
    validate_change(changeset, :file, fn :file, file ->
      if Path.extname(file.filename) == ".csv" and file.content_type == "text/csv" do
        []
      else
        [file: gettext("Uploaded file is not a valid CSV file")]
      end
    end)
  end
end
