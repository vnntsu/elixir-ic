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
      |> Changeset.traverse_errors(&translate_error_and_return_skip_field_name_option/1)
      |> Enum.map(&build_error_response(code, &1))

    %{errors: errors}
  end

  defp build_error_response(code, {field, message_and_opts}) do
    if length(message_and_opts) == 1 do
      [{message, skip_field_name}] = message_and_opts

      build_error_response(code, skip_field_name, {field, [message]})
    end
  end

  defp build_error_response(code, true = _custom_message_field?, {field, message}) do
    %{
      code: code,
      source: %{parameter: field},
      detail: to_sentence(message)
    }
  end

  defp build_error_response(code, false = _custom_message_field?, {field, message}) do
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

  defp translate_error_and_return_skip_field_name_option({msg, opts}) do
    skip_field_name = Keyword.get(opts, :skip_field_name, false)

    {translate_error({msg, opts}), skip_field_name}
  end
end
