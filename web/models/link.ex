defmodule Phlink.Link do
  @moduledoc """
  Stores the url and it's shortcode. Associated to the user that created the
  link.
  """
  use Phlink.Web, :model
  alias Phlink.Shortcode

  schema "links" do
    field :url, :string
    field :shortcode, :string
    belongs_to :user, User

    timestamps
  end

  @required_fields ~w(url user_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.

  Generates the shortcode for the url. As the shortcode generation will create
  the same shortcode for a given url there's no need to check if we're creating
  or updating the record.
  """
  def changeset(model, params \\ nil) do
    changeset = cast(model, params, @required_fields, @optional_fields)
    changeset = case get_field(changeset, :url) do
      nil -> changeset
      url -> change(changeset, %{shortcode: Shortcode.generate(url)})
    end
    changeset
    |> validate_unique(:shortcode, on: Repo)
    |> validate_url(:url)
  end

  @doc """
  Return the link that matches the url
  """
  def from_url(url) do
    Repo.one(from l in Link, where: l.url == ^url)
  end

  @doc """
  Return the link that matches the shortcode
  """
  def from_shortcode(shortcode) do
    Repo.one(from l in Link, where: l.shortcode == ^shortcode)
  end

  @doc """
  Return total number of links in the database
  """
  def count do
    Repo.one(from(l in Link, select: count(l.shortcode)))
  end

  defp validate_url(changeset, field) do
    validate_change changeset, field, fn(field, url) ->
      case :http_uri.parse(String.to_char_list(url)) do
        { :ok, _ } -> []
        { :error, _ } -> [{field, "is not a url"}]
      end
    end
  end
end
