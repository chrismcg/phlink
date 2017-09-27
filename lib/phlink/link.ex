defmodule Phlink.Link do
  @moduledoc """
  Stores the url and it's shortcode. Associated to the user that created the
  link.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Phlink.Shortcode
  alias __MODULE__

  schema "links" do
    field :url, :string
    field :shortcode, :string
    belongs_to :user, Phlink.Accounts.User

    timestamps()
  end

  @required_fields ~w(url user_id)a

  def new do
    cast(%Link{}, %{}, [])
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.

  Generates the shortcode for the url. As the shortcode generation will create
  the same shortcode for a given url there's no need to check if we're creating
  or updating the record.
  """
  def changeset(model, params \\ :invalid) do
    changeset =
      model
      |> cast(params, @required_fields)
      |> validate_required(@required_fields)
    changeset =
      case get_field(changeset, :url) do
        nil -> changeset
        url -> change(changeset, %{shortcode: Shortcode.generate(url)})
      end
    changeset
    |> unique_constraint(:shortcode)
    |> validate_url(:url)
  end

  defp validate_url(changeset, field) do
    validate_change changeset, field, fn(field, url) ->
      case :http_uri.parse(String.to_charlist(url)) do
        { :ok, _ } -> []
        { :error, _ } -> [{field, "is not a url"}]
      end
    end
  end
end
