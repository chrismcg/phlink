defmodule Phlink.GitHub.Test do
  def authorize_url!(_params \\ []) do
    "http://example.com/test"
  end

  def get_user(_code) do
    github_user()
  end

  def github_user do
    %{
      "login" => "chrismcg",
      "id" => 212,
      "avatar_url" => "https://avatars.githubusercontent.com/u/212?v=3",
      "name" => "Chris McGrath"
    }
  end
end
