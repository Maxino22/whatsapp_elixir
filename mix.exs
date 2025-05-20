defmodule WhatsappElixir.MixProject do
  use Mix.Project

  @version "0.1.6"
  @repo_url "https://github.com/Maxino22/whatsapp_elixir"

  def project do
    [
      app: :whatsapp_elixir,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: "Open source Elixir wrapper for the WhatsApp Cloud API",
      package: package(),

      # Docs
      name: "whatsapp_elixir",
      docs: [
        name: "whatsapp_elixir",
        source_ref: "v#{@version}",
        source_url: @repo_url,
        homepage_url: @repo_url,
        main: "readme",
        extras: ["README.md"],
        groups_for_modules: [
          Core: [
            WhatsappElixir,
            WhatsappElixir.Config
          ],
          Messages: [
            WhatsappElixir.Messages
          ],
          Templates: [
            WhatsappElixir.Templates
          ],
          Media: [
            WhatsappElixir.Media
          ]
        ],
        links: %{
          "GitHub" => @repo_url,
          "Templates Documentation" => "#{@repo_url}/blob/main/lib/whatsapp_elixir/templates.ex",
          "Messages Documentation" => "#{@repo_url}/blob/main/lib/whatsapp_elixir/messages.ex",
          "Media Documentation" => "#{@repo_url}/blob/main/lib/whatsapp_elixir/media.ex",
          "WhatsApp API Docs" => "https://developers.facebook.com/docs/whatsapp/cloud-api",
          "Sponsor" => "https://github.com/sponsors/Maxino22"
        }
      ]
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @repo_url,
        "Templates" => "#{@repo_url}/blob/main/lib/whatsapp_elixir/templates.ex",
        "Messages" => "#{@repo_url}/blob/main/lib/whatsapp_elixir/messages.ex",
        "Documentation" => "https://hexdocs.pm/whatsapp_elixir"
      }
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:req, "~> 0.3"},
      {:jason, "~> 1.4"},
      {:multipart, "~> 0.4.0"},
      {:mime, "~> 2.0.6"},
      {:ex_doc, "~> 0.27.0", only: :dev, runtime: false}
    ]
  end
end
