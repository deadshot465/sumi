defmodule Sumi.MixProject do
  use Mix.Project

  def project do
    [
      app: :sumi,
      version: "0.4.1",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SumiApplication, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:nostrum, "~> 0.4"},
      {:owoify_ex, "~> 0.1"}
    ]
  end
end
