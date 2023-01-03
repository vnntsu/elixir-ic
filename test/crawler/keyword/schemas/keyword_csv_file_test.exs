defmodule Crawler.Keyword.Schemas.KeywordCSVFileTest do
  use Crawler.DataCase, async: true

  alias Crawler.Keyword.Schemas.KeywordCSVFile

  describe "create_changeset/1" do
    test "given a valid file, returns valid changeset" do
      attrs = %{file: keyword_file_fixture("valid.csv")}

      changeset = KeywordCSVFile.create_changeset(%KeywordCSVFile{}, attrs)

      assert changeset.valid? == true
      assert changeset.changes == attrs
    end

    test "when file is not CSV type, returns invalid changeset" do
      attrs = %{file: keyword_file_fixture("invalid.txt")}

      changeset = KeywordCSVFile.create_changeset(%KeywordCSVFile{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{file: [gettext("Uploaded file is not a valid CSV file")]}
    end

    test "when file doesn't exist, returns invalid changeset" do
      changeset = KeywordCSVFile.create_changeset(%KeywordCSVFile{}, %{file: nil})

      assert changeset.valid? == false
      assert errors_on(changeset) == %{file: [gettext("can't be blank")]}
    end
  end
end
