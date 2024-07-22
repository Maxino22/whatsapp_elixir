defmodule WhatsappElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :whatsapp_elixir,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      description: "An Elixir library for WhatsApp API interactions",
      deps: deps()
    ]
  end

  def package do
    [
    licenses: ["MIT"],
    # links: %{"GitHub" => "https://github.com/yourusername/whatsapp_elixir"}
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
      {:req, "~> 0.3"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.27.0", only: :dev, runtime: false}
    ]
  end
end
