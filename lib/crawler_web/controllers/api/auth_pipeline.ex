defmodule CrawlerWeb.Api.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :crawler,
    module: Crawler.Account.Guardian,
    error_handler: CrawlerWeb.Api.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
  plug CrawlerWeb.Plugs.SetCurrentUser
end
