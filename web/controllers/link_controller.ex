defmodule Phlink.LinkController do
  use Phlink.Web, :controller

  alias Phlink.Link

  plug :scrub_params, "link" when action in [:create, :update]
  plug :action

  def index(conn, _params) do
    links = Repo.all(Link)
    render conn, "index.html", links: links
  end

  def new(conn, _params) do
    changeset = Link.changeset(%Link{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"link" => link_params}) do
    changeset = Link.changeset(%Link{}, link_params)

    if changeset.valid? do
      Repo.insert(changeset)

      conn
      |> put_flash(:info, "Link created successfully.")
      |> redirect(to: link_path(conn, :index))
    else
      render conn, "new.html", changeset: changeset
    end
  end

  def show(conn, %{"id" => id}) do
    link = Repo.get(Link, id)
    render conn, "show.html", link: link
  end

  def edit(conn, %{"id" => id}) do
    link = Repo.get(Link, id)
    changeset = Link.changeset(link)
    render conn, "edit.html", link: link, changeset: changeset
  end

  def update(conn, %{"id" => id, "link" => link_params}) do
    link = Repo.get(Link, id)
    changeset = Link.changeset(link, link_params)

    if changeset.valid? do
      Repo.update(changeset)

      conn
      |> put_flash(:info, "Link updated successfully.")
      |> redirect(to: link_path(conn, :index))
    else
      render conn, "edit.html", link: link, changeset: changeset
    end
  end

  def delete(conn, %{"id" => id}) do
    link = Repo.get(Link, id)
    Repo.delete(link)

    conn
    |> put_flash(:info, "Link deleted successfully.")
    |> redirect(to: link_path(conn, :index))
  end
end
