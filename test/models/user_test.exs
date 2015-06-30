defmodule Phlink.UserTest do
  use Phlink.ModelCase

  alias Phlink.User

  @valid_attrs %{
    name: "some content",
    github_id: 212,
    avatar_url: "https://avatars.githubusercontent.com/u/212?v=3",
    github_user: %{
    "login" => "chrismcg",
    "id" => 212,
    "avatar_url" => "https://avatars.githubusercontent.com/u/212?v=3",
    "name" => "Chris McGrath"
  }}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
