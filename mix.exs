defmodule Phlink.Mixfile do
  use Mix.Project

  def project do
    [app: :phlink,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     name: "phl.ink",
     source_url: "https://github.com/chrismcg/phlink",
     homepage_url: "http://phl.ink",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: {Phlink, []},
      applications: app_list(Mix.env)
    ]
  end

  defp app_list(:dev), do: [:dotenv | app_list]
  defp app_list(_), do: app_list
  defp app_list, do: [
    :phoenix,
    :phoenix_html,
    :cowboy,
    :logger,
    :phoenix_ecto,
    :postgrex,
    :hackney
  ]

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [
     {:phoenix, "~> 1.0.2"},
     {:phoenix_ecto, "~> 1.1"},
     {:phoenix_html, "~> 2.1"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:cowboy, "~> 1.0"},
     {:uuid, "~> 1.0"},
     {:oauth2, "~> 0.3"},
     {:dotenv, "~> 1.0.0"},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.10.0", only: :dev},
     {:websocket_client, git: "https://github.com/jeremyong/websocket_client.git", only: :test},
     {:excoveralls, "~> 0.3.11", only: :test}
   ]
  end
end
