defmodule Phlink.Accounts.User do
  @moduledoc """
  Stores the user details
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  schema "users" do
    field :name, :string
    field :github_id, :integer
    field :avatar_url, :string
    field :github_user, :map

    timestamps()
  end

  @required_fields ~w(name github_id avatar_url github_user)a

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
