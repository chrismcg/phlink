defmodule Phlink.Cache.Mapper do
  @moduledoc """
  Maps the shortcode to the pid of the process that's caching the URL to
  redirect to.

  Creates a new cache process if it can't find one for the shortcode in its
  internal state.

  The new cache process is monitored so when it expires we can remove it from
  the map. To protect against the pid having died but we haven't received the
  down message yet we check if the process is alive before returning the pid.
  """
  use GenServer
  alias Phlink.Cache
  alias Phlink.Repo
  import Ecto.Query, only: [from: 1, from: 2]
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
      {:miss, state} ->
        {_pid, url, state} = cache_and_update_map(shortcode, state)
        {:reply, url, state}
      # already cached so get url from cache process and return
      {:ok, pid} ->
        url = Cache.UrlCache.url(pid)
        {:reply, url, state}
    end
  end

  def handle_call({:warm, shortcode}, _from, state) do
    case cache_pid(shortcode, state) do
      # not cached so cache
      {:miss, state} ->
        {pid, _url, state} = cache_and_update_map(shortcode, state)
        {:reply, pid, state}
      # already cached so just reply with the pid
      {:ok, pid} ->
        {:reply, pid, state}
    end
  end

  def handle_info({:'DOWN', _, _, pid, _}, state) do
    remove_pid_from_map(pid, state)
    {:noreply, state}
  end

  defp cache_pid(shortcode, state) do
    case Dict.get(state.shortcodes, shortcode) do
      nil -> {:miss, state}
      pid ->
        if Process.alive?(pid) do
          {:ok, pid}
        else
          state = remove_pid_from_map(pid, state)
          {:miss, state}
        end
    end
  end

  defp remove_pid_from_map(pid, state) do
    shortcode_for_pid = Dict.get(state.pids, pid)
    state = %{state | shortcodes: Dict.delete(state.shortcodes, shortcode_for_pid)}
    state = %{state | pids: Dict.delete(state.pids, pid)}
  end

  defp cache_and_update_map(shortcode, state) do
    {pid, url} = get_and_cache(shortcode)
    state = %{state | shortcodes: Dict.put(state.shortcodes, shortcode, pid)}
    state = %{state | pids: Dict.put(state.pids, pid, shortcode)}
    {pid, url, state}
  end

  defp get_and_cache(shortcode) do
    case link_from_shortcode(shortcode) do
      nil -> { nil, nil }
      link ->
        {:ok, pid} = Cache.UrlCacheSupervisor.start_child(link.url)
        Process.monitor(pid)
        { pid, link.url }
    end
  end
 
  defp link_from_shortcode(shortcode) do
    Repo.one(from l in Link, where: l.shortcode == ^shortcode)
  end
end
