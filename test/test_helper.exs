Code.put_compiler_option(:warnings_as_errors, true)

{:ok, _} = Application.ensure_all_started(:mimic)

{:ok, _} = Application.ensure_all_started(:ex_machina)

Mimic.copy(Crawler.Account.Guardian)
Mimic.copy(Ecto.Adapters.SQL)
Mimic.copy(Floki)
Mimic.copy(HTTPoison)

{:ok, _} = Application.ensure_all_started(:wallaby)

ExUnit.start(capture_log: true)
Ecto.Adapters.SQL.Sandbox.mode(Crawler.Repo, :manual)

Application.put_env(:wallaby, :base_url, CrawlerWeb.Endpoint.url())
