use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phlink, PhlinkWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
# uncomment below to get some more debug messages if required
# config :logger, level: :warn, handle_otp_reports: true, handle_sasl_reports: true

# Configure your database
config :phlink, Phlink.Repo,
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  database: "phlink_test",
  hostname: System.get_env("DATABASE_HOST"),
  pool: Ecto.Adapters.SQL.Sandbox

config :phlink, :github_api, Phlink.GitHub.Test
