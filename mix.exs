defmodule Market.MixProject do
  use Mix.Project

  def project do
    [
      app: :market,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:faker, "~> 0.13", only: :test},

      # Static code analysis
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:sobelow, "~> 0.7", only: :dev}
    ]
  end
end
