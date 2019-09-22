use Mix.Config

config :phlink, PhlinkWeb.Endpoint,
  http: [:inet6, port: 80],
  url: [host: "phl.ink", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  root: "."

# Do not print debug messages in production
config :logger, level: :info

# Start the listeners in production
config :phoenix, serve_endpoints: true

# Configure database via URL
config :phlink, Phlink.Repo,
  url: System.get_env("DATABASE_URL"),
  ssl: true,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "18")
