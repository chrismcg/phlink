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
     preferred_cli_env: [
       "coveralls": :test,
       "coveralls.details": :test,
       "coveralls.post": :test
     ],
     name: "phl.ink",
     source_url: "https://github.com/chrismcg/phlink",
     homepage_url: "http://phl.ink",
     aliases: aliases,
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
     {:phoenix, "1.0.4"},
     {:phoenix_ecto, "~> 1.1"},
     {:phoenix_html, "~> 2.1"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:cowboy, "~> 1.0"},
     {:uuid, "~> 1.1"},
     {:oauth2, "~> 0.5"},
     {:dotenv, "~> 2.0.0"},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.11.2", only: :dev},
     {:websocket_client, git: "https://github.com/jeremyong/websocket_client.git", only: :test},
     {:excoveralls, "~> 0.4", only: :test}
   ]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"]]
  end
end
