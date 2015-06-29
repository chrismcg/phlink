defmodule Phlink.Endpoint do
  use Phoenix.Endpoint, otp_app: :phlink

  # Serve at "/" the given assets from "priv/static" directory
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
 plug Plug.Static,
    at: "/", from: :phlink, gzip: true,
    only: ~w(css images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_phlink_key",
    signing_salt: "U9/UNcn1",
    encryption_salt: "zW6iwkT7"

  plug :router, Phlink.Router
end
