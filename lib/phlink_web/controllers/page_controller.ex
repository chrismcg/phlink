defmodule PhlinkWeb.PageController do
  @moduledoc """
  Show the homepage
  """
  use PhlinkWeb, :controller

  @doc """
  If the user isn't logged in then display a login link.

  If they are logged in redirect to the new link form.
  """
  def index(conn, _params) do
    case conn.assigns[:current_user] do
      nil -> render(conn, "index.html")
      _ -> redirect(conn, to: Routes.link_path(conn, :new))
    end
  end
end
