defmodule Crawler.Home.Helpers.CSVParser do
  alias NimbleCSV.RFC4180, as: CSV

  @keywords_file_max_length 1000
  @keyword_min_length 1
  @keyword_max_length 100

  def keywords_limit, do: @keywords_file_max_length
  def keyword_min_length, do: @keyword_min_length
  def keyword_max_length, do: @keyword_max_length

  def parse(file_path) do
    case parse_keyword_list_from_file(file_path) do
      {:ok, keywords} -> validate_keywords_length(keywords)
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_keyword_list_from_file(path) do
    keywords =
      path
      |> File.stream!()
      |> CSV.parse_stream(skip_headers: false)
      |> Enum.to_list()
      |> List.flatten()

    validate_keyword_length_fn = fn element ->
      keyword_length = String.length(element)
      keyword_length < @keyword_max_length and keyword_length > @keyword_min_length
    end

    case Enum.any?(keywords, validate_keyword_length_fn) do
      true -> generate_ok(keywords)
      false -> generate_error(:keyword_length_exceeded)
    end
  end

  defp validate_keywords_length(keywords) do
    case length(keywords) do
      0 -> generate_error(:file_empty)
      length when length > @keywords_file_max_length -> generate_error(:file_length_exceeded)
      _ -> generate_ok(keywords)
    end
  end

  defp generate_error(reason), do: {:error, reason}
  defp generate_ok(result), do: {:ok, result}
end
