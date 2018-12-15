defmodule Phlink.Shortcode do
  @moduledoc """
  Shortcode Generation
  """

  @doc """
  Generate shortcode by creating v5 UUID, passing it through `phash2` to create
  an integer and converts that to a hex string.
  """
  def generate(url) do
    UUID.uuid5(:url, url, :hex)
    |> :erlang.phash2()
    |> Integer.to_string(16)
  end
end
