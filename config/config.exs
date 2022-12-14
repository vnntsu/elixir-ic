# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :crawler,
  ecto_repos: [Crawler.Repo]

# Configures the endpoint
config :crawler, CrawlerWeb.Endpoint,
  health_path: "/_health",
  url: [host: "localhost"],
  render_errors: [view: CrawlerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Crawler.PubSub,
  live_view: [signing_salt: "hakzS2sH"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :crawler, Crawler.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure dart_sass (the version is required)
config :dart_sass,
  version: "1.49.11",
  app: [
    args: ~w(
      --load-path=./node_modules
      css/app.scss
      ../priv/static/assets/app.css
      ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  app: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :crawler, Oban,
  repo: Crawler.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [
    default: 10,
    # 5 jobs per second - by pass Google threshold
    crawler: [limit: 5, dispatch_cooldown: :timer.seconds(1)]
  ]

config :jsonapi,
  remove_links: true,
  json_library: Jason,
  paginator: nil

config :crawler, Crawler.Account.Guardian, issuer: "crawler"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
