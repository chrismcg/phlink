defmodule Phlink.Cache.Mapper do
  @moduledoc """
  Maps the shortcode to the pid of the process that's caching the URL to
  redirect to.

  Creates a new cache process if it can't find one for the shortcode in its
  internal state.

  The new cache process is monitored so when it expires we can remove it from
  the map. There's a potential race condition with this where the notification
  that the cache process has died could arrive after another message to look
  up the shortcode that just expired so the internal state has a stale mapping.

  This could be solved by checking `Process.alive?` for the pid and calling
  `cache_and_update_map` if it was false. `cache_and_update_map` would have to
  be improved to remove the stale pid from the internal state in this case. The
  `handle_info(:'DOWN'...` would also need to do the right thing if the pid
  wasn't in the internal state anymore.
  """
  use GenServer
  alias Phlink.Cache
  alias Phlink.Link

  defstruct shortcodes: HashDict.new, pids: HashDict.new

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, %Cache.Mapper{}}
  end

  def handle_call({:get_url, shortcode}, _from, state) do
    case cache_pid(shortcode, state) do
      # not cached so cache
      nil ->
        {_pid, url, state} = cache_and_update_map(shortcode, state)
        {:reply, url, state}
      # already cached so get url from cache process and return
      pid ->
        url = Cache.UrlCache.url(pid)
        {:reply, url, state}
    end
  end

  def handle_call({:warm, shortcode}, _from, state) do
    case cache_pid(shortcode, state) do
      # not cached so cache
      nil ->
        {pid, _url, state} = cache_and_update_map(shortcode, state)
        {:reply, pid, state}
      # already cached so just reply with the pid
      pid ->
        {:reply, pid, state}
    end
  end

  def handle_info({:'DOWN', _, _, pid, _}, state) do
    shortcode_for_pid = Dict.get(state.pids, pid)
    state = %{state | shortcodes: Dict.delete(state.shortcodes, shortcode_for_pid)}
    state = %{state | pids: Dict.delete(state.pids, pid)}
    {:noreply, state}
  end

  defp cache_pid(shortcode, state) do
    Dict.get(state.shortcodes, shortcode)
  end

  defp cache_and_update_map(shortcode, state) do
    {pid, url} = get_and_cache(shortcode)
    state = %{state | shortcodes: Dict.put(state.shortcodes, shortcode, pid)}
    state = %{state | pids: Dict.put(state.pids, pid, shortcode)}
    {pid, url, state}
  end

  defp get_and_cache(shortcode) do
    case Link.from_shortcode(shortcode) do
      nil -> { nil, nil }
      link ->
        {:ok, pid} = Cache.UrlCacheSupervisor.start_child(link.url)
        Process.monitor(pid)
        { pid, link.url }
    end
  end
end
