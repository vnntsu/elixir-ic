defmodule CrawlerWeb.Api.V1.UserSessionView do
  use JSONAPI.View, type: "user_session"

  def fields do
    [
      :token,
      :email
    ]
  end
end
