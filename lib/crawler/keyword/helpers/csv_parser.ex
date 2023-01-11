defmodule Crawler.Keyword.Helpers.CSVParser do
  alias NimbleCSV.RFC4180, as: CSV

  @keywords_file_max_length 1000

  def keywords_limit, do: @keywords_file_max_length

  def parse(file_path) do
    keywords = parse_keyword_list_from_file(file_path)

    case validate_keywords_length(keywords) do
      {:ok, keywords} -> {:ok, keywords}
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_keyword_list_from_file(path) do
    path
    |> File.stream!()
    |> CSV.parse_stream(skip_headers: false)
    |> Enum.to_list()
    |> List.flatten()
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
