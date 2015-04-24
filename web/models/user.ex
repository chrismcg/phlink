defmodule Phlink.User do
  use Phlink.Web, :model

  schema "users" do
    field :name, :string
    field :github_id, :integer
    field :github_user, Phlink.JSONB

    timestamps
  end

  @required_fields ~w(name github_id github_user)
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
end
