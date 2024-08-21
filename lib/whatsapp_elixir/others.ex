defmodule WhatsappElixir.Others do
  @moduledoc """
  Module to handle sending custom JSON and contact messages to WhatsApp users.
  """

  require Logger
  alias WhatsappElixir.HTTP

  @doc """
  Sends a custom JSON to a WhatsApp user. This can be used to send custom objects to the message endpoint.

  ## Examples

      iex> data = %{
      ...>   "messaging_product" => "whatsapp",
      ...>   "type" => "audio",
      ...>   "audio" => %{"id" => "audio_id"}
      ...> }
      iex> recipient_id = "5511999999999"
      iex> WhatsappElixir.Others.send_custom_json(data, recipient_id)
  """
  def send_custom_json(data, recipient_id \\ "", custom_config \\ []) do
    data =
      if recipient_id != "" do
        if Map.has_key?(data, "to") do
          Logger.info("Recipient Id is defined in data (#{data["to"]}) and recipient_id parameter (#{recipient_id})")
        else
          Map.put(data, "to", recipient_id)
        end
      else
        data
      end

    Logger.info("Sending custom JSON to #{recipient_id}")
    case HTTP.post(data, custom_config) do
      {:ok, response} ->
        Logger.info("Custom JSON sent to #{recipient_id}")
        response
      {:error, reason} ->
        Logger.error("Failed to send custom JSON to #{recipient_id}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Sends a list of contacts to a WhatsApp user.

   REFERENCE: https://developers.facebook.com/docs/whatsapp/cloud-api/reference/messages#contacts-object
  ## Examples

      iex> contacts = [%{
      ...>  "name" => %{ "formatted_name" => "Maxwell Muhanda", "first_name" => "Maxwell" },
      ...>   "addresses" => [%{
      ...>     "street" => "STREET",
      ...>     "city" => "CITY",
      ...>     "state" => "STATE",
      ...>     "zip" => "ZIP",
      ...>     "country" => "COUNTRY",
      ...>     "country_code" => "COUNTRY_CODE",
      ...>     "type" => "HOME"
      ...>   }]
      ...> }]
      iex> recipient_id = "5511999999999"
      iex> WhatsappElixir.Others.send_contacts(contacts, recipient_id)
  """
  def send_contacts(contacts, recipient_id, custom_config \\ []) do
    data = %{
      "messaging_product" => "whatsapp",
      "to" => recipient_id,
      "type" => "contacts",
      "contacts" => contacts
    }

    Logger.info("Sending contacts to #{recipient_id}")
    case HTTP.post(data, custom_config) do
      {:ok, response} ->
        Logger.info("Contacts sent to #{recipient_id}")
        response
      {:error, reason} ->
        Logger.error("Failed to send contacts to #{recipient_id}: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
