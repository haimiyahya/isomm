defmodule Isomm.MixProject do
  use Mix.Project

  def project do
    [
      app: :isomm,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_iso8583, git: "https://github.com/haimiyahya/Elixir-ISO8583.git"},
    ]
  end
end
