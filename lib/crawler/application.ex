defmodule Crawler.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Crawler.Repo,
      # Start the Telemetry supervisor
      CrawlerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Crawler.PubSub},
      # Start the Endpoint (http/https)
      CrawlerWeb.Endpoint,
      {Oban, oban_config()}
      # Start a worker by calling: Crawler.Worker.start_link(arg)
      # {Crawler.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Crawler.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CrawlerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # Conditionally disable crontab, queues, or plugins here.
  defp oban_config, do: Application.get_env(:crawler, Oban)
end
