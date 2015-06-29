use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :phlink, Phlink.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Configure your database
config :phlink, Phlink.Repo,
  adapter: Ecto.Adapters.Postgres,
  size: 20, # The amount of database connections in the pool
  extensions: [{Extensions.JSON, library: Poison}],
  url: {:system, "DATABASE_URL"}
