defmodule CrawlerWeb.Api.ErrorView do
  use CrawlerWeb, :view

  alias Ecto.Changeset

  def render("error.json", %{code: code, changeset: %Changeset{} = changeset}),
    do: build_error_response(code, changeset)

  def render("error.json", %{code: code, detail: detail}),
    do: build_error_response(code: code, detail: detail)

  defp to_sentence([message]), do: message

  defp build_error_response(code, %Changeset{} = changeset) do
    errors =
      changeset
      |> Changeset.traverse_errors(&translate_error/1)
      |> Enum.map(&build_error_response(code, &1))

    %{errors: errors}
  end

  defp build_error_response(code, {field, message}) do
    %{
      code: code,
      source: %{parameter: field},
      detail: "#{Phoenix.Naming.humanize(field)} #{to_sentence(message)}"
    }
  end

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
