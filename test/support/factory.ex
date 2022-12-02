defmodule Crawler.Factory do
  use ExMachina.Ecto, repo: Crawler.Repo
  use Crawler.Accounts.UserFactory
end
