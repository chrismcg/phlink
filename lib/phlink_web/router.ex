defmodule PhlinkWeb.Router do
  use PhlinkWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :assign_current_user
  end

  pipeline :unshorten do
    plug :accepts, ["html"]
  end

  pipeline :authentication do
    plug :redirect_if_not_logged_in
  end

  scope "/auth", PhlinkWeb do
    pipe_through :browser

    get "/", AuthController, :index
    get "/callback", AuthController, :callback
  end

  scope "/", PhlinkWeb do
    pipe_through :unshorten
    get "/:shortcode", LinkController, :unshorten
  end

  scope "/", PhlinkWeb do
    pipe_through :browser
    get "/", PageController, :index
  end

  scope "/shorten", PhlinkWeb do
    pipe_through [:browser, :authentication]

    get "/new", LinkController, :new
    get "/:id", LinkController, :show
    post "/", LinkController, :create
  end

  defp assign_current_user(conn, _) do
    # we assign a user in tests so we don't have to mess with the session
    case conn.assigns[:current_user] do
      nil -> assign(conn, :current_user, get_session(conn, :current_user))
      _ -> conn
    end
  end

  defp redirect_if_not_logged_in(conn, _) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_flash(:error, "Please login")
        |> redirect(to: "/")
        |> halt()
      _ -> conn
    end
  end
end
