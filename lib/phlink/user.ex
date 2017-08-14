defmodule Phlink.User do
  @moduledoc """
  Stores the user details
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :github_id, :integer
    field :avatar_url, :string
    field :github_user, :map

    timestamps()
  end

  @required_fields ~w(name github_id avatar_url github_user)a

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    model
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
