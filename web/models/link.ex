defmodule Phlink.Link do
  use Phlink.Web, :model

  schema "links" do
    field :url, :string
    field :shortcode, :string

    timestamps
  end

  @required_fields ~w(url)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    changeset = cast(model, params, @required_fields, @optional_fields)
    case get_field(changeset, :url) do
      nil -> changeset
      url ->
        shortcode = UUID.uuid5(:url, url, :hex)
        change(changeset, %{shortcode: shortcode})
    end
  end
end
