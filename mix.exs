defmodule Crawler.MixProject do
  use Mix.Project

  def project do
    [
      app: :crawler,
      version: "0.2.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        lint: :test,
        coverage: :test,
        coveralls: :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Crawler.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "test/factories"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:compass_credo_plugin, "~> 1.0.0", [only: [:dev, :test], runtime: false]},
      {:credo, "~> 1.6.7", [only: [:dev, :test], runtime: false]},
      {:dart_sass, "~> 0.5.1", [runtime: Mix.env() == :dev]},
      {:dialyxir, "~> 1.2.0", [only: [:dev], runtime: false]},
      {:ecto_sql, "~> 3.6"},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:ex_machina, "~> 2.7.0", [only: :test]},
      {:excoveralls, "~> 0.15.0", [only: :test]},
      {:exvcr, "~> 0.13.4", [only: :test]},
      {:faker, "~> 0.17.0", [only: [:dev, :test], runtime: false]},
      {:floki, ">= 0.30.0", only: :test},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:mimic, "~> 1.7.4", [only: :test]},
      {:mix_test_interactive, "~> 1.2.2", [only: :dev, runtime: false]},
      {:nimble_template, "~> 4.5.0", only: :dev, runtime: false},
      {:oban, "~> 2.13.5"},
      {:phoenix, "~> 1.6.15"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17.5"},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, ">= 0.0.0"},
      {:sobelow, "~> 0.11.1", [only: [:dev, :test], runtime: false]},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:wallaby, "~> 0.30.1", [only: :test, runtime: false]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      prettier: "cmd ./assets/node_modules/.bin/prettier --check . --color",
      "prettier.fix": "cmd ./assets/node_modules/.bin/prettier --write . --color",
      "gettext.extract-and-merge": ["gettext.extract --merge --no-fuzzy"],
      "ecto.migrate_all": [
        "ecto.migrate --migrations-path=priv/repo/migrations --migrations-path=priv/repo/data_migrations"
      ],
      coverage: ["coveralls.html --raise"],
      codebase: [
        "cmd npm run stylelint --prefix assets",
        "cmd npm run eslint --prefix assets",
        "sobelow --config",
        "prettier",
        "credo --strict",
        "deps.unlock --check-unused",
        "format --check-formatted"
      ],
      "codebase.fix": [
        "cmd npm run stylelint.fix --prefix assets",
        "cmd npm run eslint.fix --prefix assets",
        "prettier.fix",
        "deps.clean --unlock --unused",
        "format",
        "gettext.extract --merge --no-fuzzy"
      ],
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", &migrate/1, "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": [
        "esbuild app --minify",
        "sass app --no-source-map --style=compressed",
        "cmd npm run postcss --prefix assets",
        "phx.digest"
      ]
    ]
  end

  defp migrate(_) do
    if Mix.env() == :test do
      Mix.Task.run("ecto.migrate", ["--quiet"])
    else
      Mix.Task.run("ecto.migrate_all", [])
    end
  end
end
