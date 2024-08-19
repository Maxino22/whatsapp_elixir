import Config

config :whatsapp_elixir, WhatsappElixir.HTTP,
  token: "",
  phone_number_id: "",
  verify_token: "",
  base_url: "https://graph.facebook.com",
  api_version: "v18.0"

# Finally import the config/dev.local.exs which should NOT be versioned
if File.exists?("#{Mix.env()}.local.exs") do
  import_config "#{Mix.env()}.local.exs"
else
  require Logger
  Logger.warning("Didn't find '#{Mix.env()}.local.exs'")
end
