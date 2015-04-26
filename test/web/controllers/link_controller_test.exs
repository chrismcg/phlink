defmodule Phlink.LinkControllerTest do
  use Phlink.ConnCase
  alias Phlink.Cache
  alias Phlink.User

  @url "http://example.com"
  @expected_shortcode Phlink.Shortcode.generate(@url)
  @model %Link{url: @url, shortcode: @expected_shortcode}
  @current_user %{
    id: 212,
    name: "Chris McGrath",
    avatar_url: "https://avatars.githubusercontent.com/u/212?v=3",
  }

  test "GET /shorten/new redirects if user isn't logged in" do
    assert conn()
    |> get("/shorten/new")
    |> redirected_to() == "/"
  end

  test "GET /shorten/new renders new link form" do
    assert conn()
    |> assign(:current_user, @current_user)
    |> get("/shorten/new")
    |> html_response(200) =~ ~r/<input.*?name="link\[url\]"/
  end

  test "POST /shorten creates a shortened url and redirects" do
    user = create_user
    assert Link.count == 0

    conn = conn()
    |> assign(:current_user, %{@current_user | id: user.id})
    |> post("/shorten", %{"link": %{"url": @model.url}})

    assert Link.count == 1
    link = Repo.one!(from l in Link, select: l, preload: [:user])
    assert link.shortcode == @expected_shortcode
    assert link.user_id == user.id

    assert redirected_to(conn) == "/shorten/#{link.id}"
  end

  test "POST /shorten handles when the url has already been shortened" do
    link = Repo.insert(@model)
    assert conn()
    |> assign(:current_user, @current_user)
    |> post("/shorten", %{"link": %{"url": @model.url}})
    |> redirected_to() == "/shorten/#{link.id}"
    assert Link.count == 1
  end

  test "POST /shorten errors if the url is blank" do
    assert Link.count == 0
    assert conn()
    |> assign(:current_user, @current_user)
    |> post("/shorten", %{"link": %{"url": ""}})
    |> html_response(200) =~ "Url can&#39;t be blank"
    assert Link.count == 0
  end

  test "POST /shorten errors if the url isn't a valid url" do
    assert Link.count == 0
    assert conn()
    |> assign(:current_user, @current_user)
    |> post("/shorten", %{"link": %{"url": "not a url"}})
    |> html_response(200) =~ "Url is not a url"
    assert Link.count == 0
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
    assert conn()
    |> get(@model.shortcode)
    |> redirected_to(301) == @model.url
  end

  test "GET /:shortcode reads the url from the cache if it's there" do
    Repo.insert(@model)
    Cache.warm(@model.shortcode)
    assert conn()
    |> get(@model.shortcode)
    |> redirected_to(301) == @model.url
  end

  test "GET /:shortcode handles the cache being expired" do
    Repo.insert(@model)
    pid = Cache.warm(@model.shortcode)
    send(pid, :timeout)
    assert conn()
    |> get(@model.shortcode)
    |> redirected_to(301) == @model.url
  end

  test "GET /:shortcode 404s if shortcode not present" do
    assert conn()
    |> get("/notthere")
    |> html_response(404)
  end

  defp create_user do
    user = %User{
      name: "Chris McGrath",
      github_user: %{
        avatar_url: "https://avatars.githubusercontent.com/u/212?v=3",
      }
    }
    Repo.insert(user)
  end
end
