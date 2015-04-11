defmodule Phlink.Link do
  use Phlink.Web, :model

  schema "links" do
    field :url, :string
    field :shortcode, :string

    timestamps
  end

  @required_fields ~w(url shortcode)
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
