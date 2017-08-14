use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep it away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :phlink, PhlinkWeb.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Configure your database
config :phlink, Phlink.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool_size: 18,
  url: {:system, "DATABASE_URL"}
