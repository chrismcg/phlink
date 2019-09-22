use Mix.Config

# See releases.exs for configuration that uses env variables

# Do not print debug messages in production
config :logger, level: :info

# Start the listeners in production
config :phoenix, serve_endpoints: true
