defmodule Phlink.LinkControllerTest do
  use Phlink.ConnCase

  @model %Link{url: "http://example.com", shortcode: "abc"}

  test "GET / renders new link form" do
    conn = get conn(), "/"
    assert conn.resp_body =~ ~r/<input.*?name="link\[url\]"/
  end

  test "POST /shorten creates a shortened url and redirects" do
    expected_shortcode = UUID.uuid5(:url, @model.url, :hex)
    assert link_count == 0
    conn = post conn(), "/shorten", %{"link": %{"url": @model.url}}
    assert link_count == 1
    link = Repo.one!(from l in Link, select: l)
    assert link.shortcode == expected_shortcode
    assert conn.status == 302
    assert Enum.any?(conn.resp_headers, &(&1 == {"Location", "/shorten/#{link.id}"}))
  end

  test "POST /shorten errors if the url is blank" do
    assert link_count == 0
    conn = post conn(), "/shorten", %{"link": %{"url": ""}}
    assert link_count == 0
    assert conn.status == 200
    assert conn.resp_body =~ "Url can&#39;t be blank"
  end

  test "POST /shorten errors if the url isn't a valid url" do
    assert link_count == 0
    conn = post conn(), "/shorten", %{"link": %{"url": "not a url"}}
    assert link_count == 0
    assert conn.status == 200
    assert conn.resp_body =~ "Url is invalid"
  end

  test "GET /shorten/:id displays link and short link" do
    link = Repo.insert(@model)
    conn = get conn(), "/shorten/#{link.id}"
    assert conn.resp_body =~ ~r{<a.*?href="http://example.com"}
    assert conn.resp_body =~ ~r{<a.*?href="http://localhost:4001/abc"}
  end

  test "GET /:shortcode redirects to url matching shortcode" do
    Repo.insert(@model)
    conn = get conn(), @model.shortcode
    assert conn.status == 301
    assert Enum.any?(conn.resp_headers, &(&1 == {"Location", @model.url}))
  end

  test "GET /:shortcode reads the url from the cache if it's there" do
    Repo.insert(@model)
    # warm the cache
    Phlink.Cache.cache_url(@model.shortcode, @model.url)
    conn = get conn(), @model.shortcode
    assert conn.status == 301
    assert Enum.any?(conn.resp_headers, &(&1 == {"Location", @model.url}))
  end

  test "GET /:shortcode handles the cache being expired" do
    Repo.insert(@model)
    # warm the cache
    pid = Phlink.Cache.cache_url(@model.shortcode, @model.url)
    send(pid, :timeout)
    conn = get conn(), @model.shortcode
    assert conn.status == 301
    assert Enum.any?(conn.resp_headers, &(&1 == {"Location", @model.url}))
  end

  test "GET /:shortcode 404s if shortcode not present" do
    conn = get conn(), "/notthere"
    assert conn.status == 404
  end

  def link_count do
    %{rows: [{count}]} = Ecto.Adapters.SQL.query Repo, "SELECT COUNT(*) FROM links", []
    count
  end
end
