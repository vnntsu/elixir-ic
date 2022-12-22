defmodule Crawler.Factory do
  use ExMachina.Ecto, repo: Crawler.Repo

  use Crawler.Account.UserFactory
  use Crawler.Home.KeywordFactory
end
