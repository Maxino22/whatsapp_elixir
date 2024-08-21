defmodule WhatsappElixir.Messages do
  @moduledoc """
  Module to handle WhatsApp messaging.
  """

  require Logger
  alias WhatsappElixir.HTTP
  alias WhatsappElixir.Static





   @doc """
    ## Parameters

    - `template`: The name of the template to be sent.
    - `recipient_id`: The recipient's WhatsApp ID.
    - `components`: A list of components (e.g., buttons, text) to include in the template message.
    - `lang`: (Optional) The language code for the message. Defaults to `"en_US"`.
    - `custom_config`: (Optional) A list of custom configuration options for the HTTP request.

  ## Examples

      iex> send_template("hello_world", "+2547111111111""}])
      {:ok, %{"status" => "sent"}}

      iex> send_template("welcome_template", "+2547111111111"", [], "fr_FR" , custom_configs)
      {:ok, %{"status" => "sent"}}

  ## Returns

    - `{:ok, response}`: On success, returns `:ok` and the HTTP response.
    - `{:error, response}`: On failure, returns `:error` and the HTTP response.

  """
  def send_template(template, recipient_id, components, lang \\ "en_US", custom_config \\ []) do
    data = %{
      "messaging_product" => "whatsapp",
      "to" => recipient_id,
      "type" => "template",
      "template" => %{
        "name" => template,
        "language" => %{"code" => lang},
        "components" => components
      }
    }

    Logger.info("Sending template to #{recipient_id}")

    case HTTP.post(data, custom_config) do
      {:ok, response} ->
        Logger.info("Template sent to #{recipient_id}")
        {:ok, response}

      {:error, response} ->
        Logger.error("Template not sent to #{recipient_id}")
        Logger.error("Response: #{inspect(response)}")
        {:error, response}
    end
  end

   @doc """
  Marks a message as read.
  """
  def mark_as_read(message_id, custom_config \\ []) do
    payload = %{
      "messaging_product" => "whatsapp",
      "status" => "read",
      "message_id" => message_id
    }

    case HTTP.post(payload, custom_config) do
      {:ok, response} ->
        Logger.info("Message marked as read: #{inspect(response)}")
        {:ok, response}

      {:error, response} ->
        Logger.error("Failed to mark message as read: #{inspect(response)}")
        {:error, response}
    end
  end


  @doc """
  Replies to a message with a given text.
  """
  def reply(data, reply_text \\ "", custom_config \\ [], preview_url \\ true) do
    author = get_author(data)

    payload = %{
      "messaging_product" => "whatsapp",
      "recipient_type" => "individual",
      "to" => author,
      "type" => "text",
      "context" => %{"message_id" => get_message_id(data)},
      "text" => %{"preview_url" => preview_url, "body" => reply_text}
    }

    Logger.info("Replying to #{get_message_id(data)}")

    case HTTP.post(payload, custom_config) do
      {:ok, response} ->
        Logger.info("Message sent to #{author}")
        {:ok, response}

      {:error, response} ->
        Logger.error("Message not sent to #{author}")
        Logger.error("Response: #{inspect(response)}")
        {:error, response}
    end
  end


   @doc """
  Sends a text message.
  """
  def send_message(to, content,  custom_config \\ [], preview_url \\ true) do
    data = %{
      "messaging_product" => "whatsapp",
      "recipient_type" => "individual",
      "to" => to,
      "type" => "text",
      "text" => %{"preview_url" => preview_url, "body" => content}
    }

    Logger.info("Sending message to #{to}")

    case HTTP.post(data, custom_config) do
      {:ok, response} ->
        Logger.info("Message sent to #{to}")
        {:ok, response}

      {:error, response} ->
        Logger.error("Message not sent to #{to}")
        Logger.error("Response: #{inspect(response)}")
        {:error, response}
    end
  end


  defp get_author(data) do
    Static.get_author(data)
  end

  defp get_message_id(data) do
    Static.get_message_id(data)
  end

end
