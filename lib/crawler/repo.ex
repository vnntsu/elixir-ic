defmodule Crawler.Repo do
  use Ecto.Repo,
    otp_app: :crawler,
    adapter: Ecto.Adapters.Postgres
end
