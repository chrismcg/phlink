defmodule Phlink.Cache do
  @moduledoc """
  External API for the shortcode to URL cache
  """
  alias Phlink.Cache

  @doc """
  Returns the url for the shortcode or nil if it's not a valid shortcode.

  If the shortcode isn't in the cache it will be placed there for 5 minutes
  """
  @spec get_url(binary) :: binary | none
  def get_url(shortcode) do
    GenServer.call(Cache.Mapper, {:get_url, shortcode})
  end

  @doc """
  Returns the pid for the process caching the shortcode or nil if it's not a
  valid shortcode.

  If the shortcode isn't in the cache it will be placed there for 5 minutes
  """
  @spec warm(binary) :: binary | none
  def warm(shortcode) do
    GenServer.call(Cache.Mapper, {:warm, shortcode})
  end
end
