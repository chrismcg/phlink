defmodule Phlink.LinkController do
  use Phlink.Web, :controller

  alias Phlink.Link
  alias Phlink.Cache

  plug :scrub_params, "link" when action in [:create]
  plug :action

  def new(conn, _params) do
    changeset = Link.changeset(%Link{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"link" => link_params}) do
    # try to find an existing url
    link = case link_params["url"] do
      nil -> nil
      url -> Repo.one(from l in Link, where: l.url == ^url)
    end

    do_create(conn, link, link_params)
  end

  # when the url hasn't been shortened before try to create the short version
  defp do_create(conn, nil, link_params) do
    changeset = Link.changeset(%Link{}, link_params)
    if changeset.valid? do
      link = Repo.insert(changeset)
      Cache.warm(link.shortcode)

      conn
      |> redirect(to: link_path(conn, :show, link.id))
    else
      render conn, "new.html", changeset: changeset
    end
  end
  # when the url has been shortened before just show the existing record
  defp do_create(conn, link, _link_params) do
    Cache.warm(link.shortcode)
    conn
    |> redirect(to: link_path(conn, :show, link.id))
  end

  def show(conn, %{"id" => id}) do
    link = Repo.get(Link, id)
    render conn, "show.html", link: link
  end

  def unshorten(conn, %{"shortcode" => shortcode}) do
    case Phlink.Cache.get_url(shortcode) do
      nil ->
        conn
        |> fetch_session
        |> fetch_flash
        |> put_status(:not_found)
        |> render(Phlink.ErrorView, "404.html")
      url ->
        conn
        |> put_status(:moved_permanently)
        |> redirect(external: url)
    end
  end
end
