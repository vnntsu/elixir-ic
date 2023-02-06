defmodule CrawlerWeb.Api.V1.UserRegistrationView do
  use JSONAPI.View, type: "user_registration"

  def fields do
    [
      :token,
      :email
    ]
  end
end
