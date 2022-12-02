## Erlang & Elixir

- Erlang 25.0.4

- Elixir 1.14.0

### Node

- Node 16.15.0

- Recommended version manager.

  - [asdf](https://github.com/asdf-vm/asdf)
  - [asdf-erlang](https://github.com/asdf-vm/asdf-erlang)
  - [asdf-elixir](https://github.com/asdf-vm/asdf-elixir)

  - [asdf-node](https://github.com/asdf-vm/asdf-node)


## Development

- Install [Docker for Mac](https://docs.docker.com/docker-for-mac/install/)

- Setup and boot the Docker containers:

  ```sh
  make docker_setup
  ```

- Install Elixir dependencies:

  ```sh
  mix do deps.get, deps.compile
  ```

- Install Node dependencies:

  ```sh
  npm install --prefix assets
  ```

- Install `chromedriver` for Wallaby browser tests

  Homebrew

  ```sh
  brew install --cask chromedriver
  ```

  Debian/Ubuntu

  ```sh
  brew install --cask chromedriver
  ```

- Setup the databases:

  ```sh
  mix ecto.setup
  ```

- Start the Phoenix app

  ```sh
  iex -S mix phx.server
  ```

- Run all tests:

  ```sh
  mix test
  ```

- Run tests with `watch` option:

  ```sh
  mix test.interactive # Watch the whole test suite

  mix test.interactive test_file_path # Watch a specific test file

  mix test.interactive test_file_path:line_number # Watch a specific test line number
  ```

- Run all lint:

  ```sh
  mix codebase
  ```

- Fix all lint:

  ```sh
  mix codebase.fix
  ```

- Test coverage:

  ```sh
  mix coverage
  ```

## Production

- Build Docker image

  ```sh
  docker-compose build
  ```
