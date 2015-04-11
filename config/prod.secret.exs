use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :phlink, Phlink.Endpoint,
  secret_key_base: "uIlMaQeBPzRL//YfeO3CgSfxkJksNrHDOO2KjwXJYOZMTMm5iV1c6j8zE+XFAXQR"

# Configure your database
config :phlink, Phlink.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "phlink_prod"
