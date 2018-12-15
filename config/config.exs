# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :phlink,
  ecto_repos: [Phlink.Repo]

# Configures the endpoint
config :phlink, PhlinkWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HOHPGn11S+1dDx+zMcOye6TFICJKxTEwQRTCfHLDmXrxt2DLanXQdvEIwyxIESFw",
  render_errors: [view: PhlinkWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Phlink.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
