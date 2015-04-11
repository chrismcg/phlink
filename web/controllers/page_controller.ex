defmodule Phlink.PageController do
  use Phlink.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end
end
