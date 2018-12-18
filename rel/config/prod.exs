use Mix.Config

config :phlink, PhlinkWeb.Endpoint,
  http: [:inet6, port: System.get_env("PORT")],
  url: [host: System.get_env("HOST"), port: System.get_env("URL_PORT")],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  root: "."

config :phoenix, serve_endpoints: true

# Configure your database
config :phlink, Phlink.Repo,
  pool_size: 18,
  url: System.get_env("DATABASE_URL")
