defmodule PhlinkWeb.LinkController do
  @moduledoc """
  Handles creating shortlinks and redirecting to the original URL.
  Requires that the user is logged in.
  """
  use PhlinkWeb, :controller

  plug :scrub_params, "link" when action in [:create]

  @doc """
  Display form for user to enter a URL to shorten
  """
  def new(conn, _params) do
    changeset = Link.new()
    render(conn, "new.html", changeset: changeset)
  end

  @doc """
  Create a shortened URL.

  If there are errors the form will be redisplayed.

  If the url has already been shortened it just shows the existing record.

  If all is good and the url hasn't been shortened yet it generates the
  shortcode and also adds the current user to the record.

  Either success path will warm the cache with the shortcode on the assumption
  it will be used soon.
  """
  def create(conn, %{"link" => link_params}) do
    # try to find an existing url
    link =
      case link_params["url"] do
        nil -> nil
        url -> link_from_url(url)
      end

    do_create(conn, link, link_params)
  end

  # when the url hasn't been shortened before try to create the short version
  defp do_create(conn, nil, link_params) do
    link_params = Map.merge(link_params, %{"user_id" => conn.assigns[:current_user].id})
    changeset = Link.changeset(%Link{}, link_params)

    if changeset.valid? do
      link = Repo.insert!(changeset)
      Cache.warm(link.shortcode)

      conn
      |> redirect(to: Routes.link_path(conn, :show, link.id))
    else
      render(conn, "new.html", changeset: changeset)
    end
  end

  # when the url has been shortened before just show the existing record
  defp do_create(conn, link, _link_params) do
    Cache.warm(link.shortcode)

    conn
    |> redirect(to: Routes.link_path(conn, :show, link.id))
  end

  @doc """
  Display the shortlink and the target url
  """
  def show(conn, %{"id" => id}) do
    link = Repo.get(Link, id)
    render(conn, "show.html", link: link)
  end

  @doc """
  Redirect to the target url.

  If the shortcode wasn't in the cache then add it.

  If the shortcode isn't in the database render a 404.
  """
  def unshorten(conn, %{"shortcode" => shortcode}) do
    case Phlink.Cache.get_url(shortcode) do
      nil ->
        conn
        |> fetch_session
        |> fetch_flash
        |> put_status(:not_found)
        |> put_view(PhlinkWeb.ErrorView)
        |> render("404.html")

      url ->
        conn
        |> put_status(:moved_permanently)
        |> redirect(external: url)
    end
  end

  defp link_from_url(url) do
    Repo.one(from l in Link, where: l.url == ^url)
  end
end
