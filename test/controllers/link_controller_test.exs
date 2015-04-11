defmodule Phlink.LinkControllerTest do
  use Phlink.ConnCase

  test "GET / renders new link form" do
    conn = get conn(), "/"
    assert conn.resp_body =~ ~r/<input.*?name="link\[url\]"/
  end

  test "POST /shorten creates a shortened url and redirects" do
    assert link_count == 0
    conn = post conn(), "/shorten", %{"link": %{"url": "http://test.com"}}
    assert link_count == 1
    assert conn.status == 302
  end

  test "GET /shorten/:id displays link and short link" do
    link = Repo.insert(%Link{url: "http://example.com", shortcode: "abc"})
    conn = get conn(), "/shorten/#{link.id}"
    assert conn.resp_body =~ ~r{<a.*?href="http://example.com"}
    assert conn.resp_body =~ ~r{<a.*?href="http://phl.ink/abc"}
  end

  test "GET /:shortcode redirects to url matching shortcode" do
    link = Repo.insert(%Link{url: "http://example.com", shortcode: "abc"})
    conn = get conn(), "/abc"
    assert conn.status == 301
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
