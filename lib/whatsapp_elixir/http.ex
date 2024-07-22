defmodule WhatsappElixir.HTTP do
 @moduledoc """
  Module to handle HTTP requests for the WhatsApp Elixir library.
  """

require Logger
alias Req.Response

@doc """
Sends a POST request to the specified endpoint with the given body.
"""
def post(body) do
  base_url = Application.get_env(:whatsapp_elixir, :base_url, "https://graph.facebook.com/v18.0")
  phone_number_id = Application.get_env(:whatsapp_elixir, :phone_number_id)
  url = "#{base_url}/#{phone_number_id}/messages"

  Req.post(url, body: Jason.encode!(body), headers: headers())
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

defp headers() do
  token = Application.get_env(:whatsapp_elixir, :token)

  [
    {"Content-Type", "application/json"},
    {"Authorization", "Bearer #{token}"}
  ]
end
end
