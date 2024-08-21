defmodule WhatsappElixir.Buttons do
   @moduledoc """
  Module to handle sending interactive buttons to WhatsApp users.
  """

  require Logger
  alias WhatsappElixir.HTTP

  defp create_button(button) do
    data = %{"type" => "list", "action" => button["action"]}

    data =
      if button["header"] do
        Map.put(data, "header", %{"type" => "text", "text" => button["header"]})
      else
        data
      end

    data =
      if button["body"] do
        Map.put(data, "body", %{"text" => button["body"]})
      else
        data
      end

    if button["footer"] do
      Map.put(data, "footer", %{"text" => button["footer"]})
    else
      data
    end
  end

  @doc """
  Sends an interactive buttons message to a WhatsApp user.

  ## Examples

      iex> button = %{"header" => "Header Text", "body" => "Body Text","action" => %{"button" => "Button Text", "sections" => [%{ "title" =>"iBank", "rows" => [%{"id" => "row 1", "title" => "Send Money", "description" => ""},%{"id" => "row 2", "title" => "Withdraw money", "description" => ""}] }] }, "footer" => "Footer Text"}
      iex> recipient_id = "5511999999999"
      iex> WhatsappElixir.Buttons.send_button(button, recipient_id)

  """
  def send_button(button, recipient_id) do
    data = %{
      "messaging_product" => "whatsapp",
      "to" => recipient_id,
      "type" => "interactive",
      "interactive" => create_button(button)
    }

    Logger.info("Sending buttons to #{recipient_id}")
    case HTTP.post(data) do
      {:ok, response} ->
        Logger.info("Buttons sent to #{recipient_id}")
        response
      {:error, reason} ->
        Logger.error("Failed to send buttons to #{recipient_id}: #{inspect(reason)}")
        {:error, reason}
    end
  end

   @doc """
  Sends an interactive reply buttons (menu) message to a WhatsApp user.

  Note:
        The maximum number of buttons is 3, more than 3 buttons will rise an error.

  ## Examples

      iex> button = %{ "type" => "button", "body" => %{"text" => "button"},  "action" => %{"buttons" => [%{"type" => "reply", "reply" => %{"id" => "1", "title" => "Button 1"}}, %{"type" => "reply", "reply" => %{"id" => "2", "title" => "Button 2"}}, %{"type" => "reply", "reply" => %{"id" => "3", "title" => "Button 3"}}]}}
      iex> recipient_id = "5511999999999"
      iex> WhatsappElixir.Buttons.send_reply_button(button, recipient_id)

  """
  def send_reply_button(button, recipient_id) do
    if length(button["action"]["buttons"]) > 3 do
      raise ArgumentError, "The maximum number of buttons is 3."
    end

    data = %{
      "messaging_product" => "whatsapp",
      "recipient_type" => "individual",
      "to" => recipient_id,
      "type" => "interactive",
      "interactive" => button
    }

    Logger.info("Sending reply buttons to #{recipient_id}")
    case HTTP.post(data) do
      {:ok, response} ->
        Logger.info("Reply buttons sent to #{recipient_id}")
        response
      {:error, reason} ->
        Logger.error("Failed to send reply buttons to #{recipient_id}: #{inspect(reason)}")
        {:error, reason}
    end
  end





end
