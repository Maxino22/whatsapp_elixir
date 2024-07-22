# WhatsappElixir

**WhatsappElixir** is an Elixir library for interacting with the WhatsApp API. It allows you to handle incoming messages and send responses efficiently using a clean and simple API.

## Installation

To use **WhatsappElixir** in your project, add it to your `mix.exs` dependencies:


```elixir
def deps do
  [
    {:whatsapp_elixir, git: "git@bitbucket.org:bitfactor/whatsapp_elixir.git"}
  ]
end
```

 ## Configuration

  Configure your WhatsApp credentials in `config/config.exs`:

      config :whatsapp_elixir,
        token: System.get_env("WHATSAPP_TOKEN"),
        phone_number_id: System.get_env("WHATSAPP_PHONE_NUMBER_ID")

  """


