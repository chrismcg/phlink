defmodule Phlink.Cache.Mapper do
  use GenServer

  alias Phlink.Link
  alias Phlink.Repo
  import Ecto.Query, only: [from: 2]

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get_url(shortcode) do
    GenServer.call(__MODULE__, {:get_url, shortcode})
  end

  def init([]) do
    {:ok, %{}}
  end

  def handle_call({:get_url, shortcode}, _from, state) do
    link = Repo.one(from l in Link, where: l.shortcode == ^shortcode)

    # TODO: see if shortcode is in state, if not look up from db, and cache
    # result. See if it's possible to reply with the value before performing
    # the cache (but watch for race condition if two requests for same url)
    # maybe spawn a background worker and use the _from and reply to handle
    # this
    {:reply, link, state}
  end
end
