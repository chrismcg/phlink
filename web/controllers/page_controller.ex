defmodule Phlink.PageController do
  use Phlink.Web, :controller

  plug :action

  def index(conn, _params) do
    case conn.assigns[:current_user] do
      nil -> render(conn, "index.html")
      _ -> redirect(conn, to: link_path(conn, :new))
    end
  end
end
