defmodule WhatsappElixir.HTTP do
  @moduledoc """
  Module to handle HTTP requests for the WhatsApp Elixir library.
  """

  require Logger
  alias Req.Response

  @default_config [
    token: "",
    phone_number_id: "",
    verify_token: "",
    base_url: "https://graph.facebook.com/",
    api_version: "v18.0"
  ]

  def config(custom_config \\ []) do
    app_config = Application.get_env(:whatsapp_elixir, __MODULE__, @default_config)
    Keyword.merge(@default_config, Keyword.merge(app_config, custom_config))
  end

  def base_url(custom_config \\ []) do
    config(custom_config) |> Keyword.get(:base_url)
  end

  def api_version(custom_config \\ []) do
    config(custom_config) |> Keyword.get(:api_version)
  end

  @doc """
  Sends a POST request to the specified endpoint with the given body.
  """
  def post(body, opts \\ []) do
    config_opts = config(opts)
    phone_number_id = config(config_opts) |> Keyword.get(:phone_number_id)
    if phone_number_id == ""  do
      raise ArgumentError, "phone_number_id must be provided"
    end

    token = config(config_opts) |> Keyword.get(:token)

    if token == ""  do
      raise ArgumentError, "Missing App Token"
    end
    url = "#{base_url(config_opts)}/#{api_version(config_opts)}/#{phone_number_id}/messages"



    case Req.post(url, body: Jason.encode!(body), headers: headers(token)) do
      {:ok, %Response{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %Response{status: status, body: body}} ->
        Logger.error("[WHATSAPP_ELIXIR] HTTP request failed with status #{status}: #{inspect(body)}")
        {:error, body}

      {:error, reason} ->
        Logger.error("HTTP request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp headers(token) do

    [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{token}"}
    ]
  end
end
