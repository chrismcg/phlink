defmodule Phlink.Link do
  use Phlink.Web, :model
  alias Phlink.Repo
  alias Phlink.User

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
  """
  def changeset(model, params \\ nil) do
    changeset = cast(model, params, @required_fields, @optional_fields)
    changeset = case get_field(changeset, :url) do
      nil -> changeset
      url ->
        shortcode = UUID.uuid5(:url, url, :hex)
                    |> :erlang.phash2
                    |> Integer.to_string(16)
        change(changeset, %{shortcode: shortcode})
    end
    changeset
    |> validate_unique(:shortcode, on: Repo)
    |> validate_url(:url)
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
