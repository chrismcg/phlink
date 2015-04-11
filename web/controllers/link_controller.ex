defmodule Phlink.LinkController do
  use Phlink.Web, :controller

  alias Phlink.Link

  plug :scrub_params, "link" when action in [:create]
  plug :action

  def new(conn, _params) do
    changeset = Link.changeset(%Link{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"link" => link_params}) do
    changeset = Link.changeset(%Link{}, link_params)

    if changeset.valid? do
      link = Repo.insert(changeset)

      conn
      |> redirect(to: link_path(conn, :show, link.id))
    else
      render conn, "new.html", changeset: changeset
    end
  end

  def show(conn, %{"id" => id}) do
    link = Repo.get(Link, id)
    render conn, "show.html", link: link
  end

  def unshorten(conn, %{"shortcode" => shortcode}) do
    case Repo.one(from l in Link, where: l.shortcode == ^shortcode) do
      nil -> conn |> put_status(:not_found)
      link ->
        conn
        |> put_status(:moved_permanently)
        |> redirect(external: "http://phl.ink/#{link.shortcode}")
    end
  end
end
