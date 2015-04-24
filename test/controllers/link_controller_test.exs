defmodule Phlink.LinkControllerTest do
  use Phlink.ConnCase
  alias Phlink.Cache

  @url "http://example.com"
  @expected_shortcode UUID.uuid5(:url, @url, :hex) |> :erlang.phash2 |> Integer.to_string(16)
  @model %Link{url: @url, shortcode: @expected_shortcode}
  @current_user %{
    id: 212,
    avatar_url: "https://avatars.githubusercontent.com/u/212?v=3",
    name: "Chris McGrath"
  }

  test "GET /shorten/new redirects if user isn't logged in" do
    conn = get conn(), "/shorten/new"
    assert html_response(conn, 302)
    assert {"location", "/"} = List.keyfind(conn.resp_headers, "location", 0)
  end

  test "GET /shorten/new renders new link form" do
    conn = conn()
    |> assign(:current_user, @current_user)
    |> get("/shorten/new")
    assert html_response(conn, 200) =~ ~r/<input.*?name="link\[url\]"/
  end

  test "POST /shorten creates a shortened url and redirects" do
    assert link_count == 0

    conn = conn()
    |> assign(:current_user, @current_user)
    |> post("/shorten", %{"link": %{"url": @model.url}})

    assert link_count == 1
    link = Repo.one!(from l in Link, select: l)
    assert link.shortcode == @expected_shortcode
    assert html_response(conn, 302)
    assert Enum.any?(conn.resp_headers, &(&1 == {"location", "/shorten/#{link.id}"}))
  end

  test "POST /shorten handles when the url has already been shortened" do
    link = Repo.insert(@model)
    conn = conn()
    |> assign(:current_user, @current_user)
    |> post("/shorten", %{"link": %{"url": @model.url}})
    assert link_count == 1
    assert html_response(conn, 302)
    assert Enum.any?(conn.resp_headers, &(&1 == {"location", "/shorten/#{link.id}"}))
  end

  test "POST /shorten errors if the url is blank" do
    assert link_count == 0
    conn = conn()
    |> assign(:current_user, @current_user)
    |> post("/shorten", %{"link": %{"url": ""}})
    assert link_count == 0
    assert html_response(conn, 200) =~ "Url can&#39;t be blank"
  end

  test "POST /shorten errors if the url isn't a valid url" do
    assert link_count == 0
    conn = conn()
    |> assign(:current_user, @current_user)
    |> post("/shorten", %{"link": %{"url": "not a url"}})
    assert link_count == 0
    assert html_response(conn, 200) =~ "Url is not a url"
  end

  test "GET /shorten/:id displays link and short link" do
    link = Repo.insert(@model)
    conn = conn()
    |> assign(:current_user, @current_user)
    |> get("/shorten/#{link.id}")
    assert html_response(conn, 200) =~ ~r{<a.*?href="http://example.com"}
    assert html_response(conn, 200) =~ ~r{<a.*?href="http://localhost:4001/#{@expected_shortcode}"}
  end

  test "GET /:shortcode redirects to url matching shortcode" do
    Repo.insert(@model)
    conn = get conn(), @model.shortcode
    assert html_response(conn, 301)
    assert Enum.any?(conn.resp_headers, &(&1 == {"location", @model.url}))
  end

  test "GET /:shortcode reads the url from the cache if it's there" do
    Repo.insert(@model)
    Cache.warm(@model.shortcode)
    conn = get conn(), @model.shortcode
    assert html_response(conn, 301)
    assert Enum.any?(conn.resp_headers, &(&1 == {"location", @model.url}))
  end

  test "GET /:shortcode handles the cache being expired" do
    Repo.insert(@model)
    pid = Cache.warm(@model.shortcode)
    send(pid, :timeout)
    conn = get conn(), @model.shortcode
    assert html_response(conn, 301)
    assert Enum.any?(conn.resp_headers, &(&1 == {"location", @model.url}))
  end

  test "GET /:shortcode 404s if shortcode not present" do
    conn = get conn(), "/notthere"
    assert html_response(conn, 404)
  end

  def link_count do
    from(l in Link, select: count(l.shortcode)) |> Repo.one
  end
end
