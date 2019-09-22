import Config

config :phlink, PhlinkWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  url: [host: "phl.ink", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE"),
  root: "."

# Configure database via URL
config :phlink, Phlink.Repo,
  url: System.get_env("DATABASE_URL"),
  ssl: true,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "18")
