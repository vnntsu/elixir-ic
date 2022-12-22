defmodule Crawler.Home.KeywordFactory do
  alias Crawler.Home.Schemas.Keyword

  defmacro __using__(_opts) do
    quote do
      def keyword_factory(attrs) do
        user_id = attrs[:user_id] || insert(:user).id

        keyword = %Keyword{
          name: Faker.Lorem.word(),
          user_id: user_id
        }

        keyword
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end

      def keyword_file_fixture(file_path) do
        file_path = Path.join(["test/support/fixtures/files", file_path])

        %Plug.Upload{
          path: file_path,
          filename: Path.basename(file_path),
          content_type: MIME.from_path(file_path)
        }
      end
    end
  end
end
