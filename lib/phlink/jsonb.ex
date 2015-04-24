defmodule Phlink.JSONB do
  @behaviour Ecto.Type

  def type, do: :jsonb

  def cast(any), do: {:ok, any}
  def load(value), do: Poison.decode(value)
  def dump(value), do: Poison.encode(value)
end
