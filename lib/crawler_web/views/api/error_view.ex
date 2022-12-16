defmodule CrawlerWeb.Api.ErrorView do
  use CrawlerWeb, :view

  def render("error.json", %{code: code, detail: detail}),
    do: build_error_response(code: code, detail: detail)

  defp build_error_response(code: code, detail: detail) do
    %{
      errors: [
        %{
          code: code,
          detail: detail
        }
      ]
    }
  end
end
