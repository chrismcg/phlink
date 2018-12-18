use Mix.Config

config :phlink, PhlinkWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT"))],
  url: [host: System.get_env("HOST") || "phl.ink", port: String.to_integer(System.get_env("URL_PORT") || "80")],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  root: "."

# Do not print debug messages in production
config :logger, level: :info

# Start the listeners in production
config :phoenix, serve_endpoints: true

# Configure database via URL
config :phlink, Phlink.Repo,
  pool_size: 18,
  url: System.get_env("DATABASE_URL")
