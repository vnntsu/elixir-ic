defmodule Crawler.Keyword.Helpers.CSVParserTests do
  use Crawler.DataCase, async: true

  alias Crawler.Keyword.Helpers.CSVParser

  describe "parse/1" do
    test "given valid keywords file, returns the keywords list" do
      %{path: file_path} = keyword_file_fixture("valid.csv")

      assert CSVParser.parse(file_path) == {:ok, ["one", "two", "three"]}
    end

    test "given an empty keywords file, returns an error" do
      %{path: file_path} = keyword_file_fixture("empty.csv")

      assert CSVParser.parse(file_path) == {:error, :file_empty}
    end

    test "given an big keywords file, returns an error" do
      %{path: file_path} = keyword_file_fixture("big.csv")

      assert CSVParser.parse(file_path) == {:error, :file_length_exceeded}
    end

    test "given an file with invalid keywords, returns an error" do
      %{path: file_path} = keyword_file_fixture("non_valid.csv")

      assert CSVParser.parse(file_path) == {:error, :keyword_length_exceeded}
    end
  end
end
