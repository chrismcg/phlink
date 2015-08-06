defmodule Phlink.User do
  @moduledoc """
  Stores the user details
  """
  use Phlink.Web, :model

  schema "users" do
    field :name, :string
    field :github_id, :integer
    field :avatar_url, :string
    field :github_user, :map

    timestamps
  end

  @required_fields ~w(name github_id avatar_url github_user)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  @doc """
  Return the user with the given github_id
  """
  def from_github_id(github_id) do
    Repo.one(from u in User, where: u.github_id == ^github_id)
  end

  @doc """
  Return total number of users in the database
  """
  def count do
    Repo.one(from(u in User, select: count(u.id)))
  end
end
