defmodule WhatsappElixir.HTTP do
  @moduledoc """
  Module to handle HTTP requests for the WhatsApp Elixir library.
  """

  require Logger
  alias Req.Response

  def config() do
    Application.get_env(:whatsapp_elixir, __MODULE__)
  end

  def api_version(), do: config() |> Keyword.get(:api_version)

  def base_url(), do: config() |> Keyword.get(:base_url)

  @doc """
  Sends a POST request to the specified endpoint with the given body.
  """
  def post(body, opts \\ []) do
    phone_number_id =
      Keyword.get(opts, :phone_number_id) ||
        Application.get_env(:whatsapp_elixir, :phone_number_id) ||
        raise ArgumentError,
          message:
            "You must provide a phone_number_id on the function parameter or through the #{__MODULE__} config"

    token =
      Keyword.get(opts, :token) ||
        Application.get_env(:whatsapp_elixir, :token) ||
        raise ArgumentError,
          message:
            "You must provide a token on the function parameter or through the #{__MODULE__} config"

    url = "#{base_url()}/#{api_version()}" <> "/#{phone_number_id}/messages"

    Req.post(url, body: Jason.encode!(body), headers: headers(token))
    |> parse_response()
  end

  defp parse_response({:ok, %Response{status: status, body: body}}) when status in 200..299 do
    {:ok, body}
  end

  defp parse_response({:ok, %Response{status: status, body: body}}) do
    Logger.error("[WHATSAPP_ELIXIR] HTTP request failed with status #{status}: #{inspect(body)}")
    {:error, body}
  end

  defp parse_response({:error, reason}) do
    Logger.error("HTTP request failed: #{inspect(reason)}")
    {:error, reason}
  end

  defp headers(token) do
    [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{token}"}
    ]
  end
end
