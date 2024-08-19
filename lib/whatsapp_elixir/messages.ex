defmodule WhatsappElixir.Messages do
  @moduledoc """
  Module to handle WhatsApp messaging.
  """

  require Logger
  alias WhatsappElixir.HTTP
  alias WhatsappElixir.Static

  @doc """
  Sends a template message to a WhatsApp user.
  """
  def send_template(template, recipient_id, components, lang \\ "en_US") do
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

    case HTTP.post(data) do
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
  def mark_as_read(message_id) do
    payload = %{
      "messaging_product" => "whatsapp",
      "status" => "read",
      "message_id" => message_id
    }

    case HTTP.post(payload) do
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
  def reply(data, reply_text \\ "", preview_url \\ true) do
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

    case HTTP.post(payload) do
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
  def send_message(to, content, preview_url \\ true) do
    data = %{
      "messaging_product" => "whatsapp",
      "recipient_type" => "individual",
      "to" => to,
      "type" => "text",
      "text" => %{"preview_url" => preview_url, "body" => content}
    }

    Logger.info("Sending message to #{to}")

    case HTTP.post(data) do
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
