defmodule WhatsappElixir.Static do
  @moduledoc """
  Utility functions for processing data received from the WhatsApp webhook.
  """

  @doc """
  Checks if the data received from the webhook is a message.
  """
  def is_message(data) do
    data = data["entry"]
    |> List.first()
    |> Map.get("changes")
    |> List.first()
    |> Map.get("value")

    Map.has_key?(data, "messages")
  end

  @doc """
  Extracts the mobile number of the sender from the data received from the webhook.
  """
  def get_mobile(data) do
    data = data["entry"]
    |> List.first()
    |> Map.get("changes")
    |> List.first()
    |> Map.get("value")

    if Map.has_key?(data, "contacts") do
      data["contacts"]
      |> List.first()
      |> Map.get("wa_id")
    else
      nil
    end
  end

  @doc """
  Extracts the name of the sender from the data received from the webhook.
  """
  def get_name(data) do
    contact = data["entry"]
    |> List.first()
    |> Map.get("changes")
    |> List.first()
    |> Map.get("value")

    if contact do
      contact["contacts"]
      |> List.first()
      |> Map.get("profile")
      |> Map.get("name")
    else
      nil
    end
  end

  @doc """
  Extracts the text message of the sender from the data received from the webhook.
  """
  def get_message(data) do
    data = data["entry"]
    |> List.first()
    |> Map.get("changes")
    |> List.first()
    |> Map.get("value")

    if Map.has_key?(data, "messages") do
      data["messages"]
      |> List.first()
      |> Map.get("text")
      |> Map.get("body")
    else
      nil
    end
  end

  @doc """
  Extracts the message id of the sender from the data received from the webhook.
  """
  def get_message_id(data) do
    data = data["entry"]
    |> List.first()
    |> Map.get("changes")
    |> List.first()
    |> Map.get("value")

    if Map.has_key?(data, "messages") do
      data["messages"]
      |> List.first()
      |> Map.get("id")
    else
      nil
    end
  end

  @doc """
  Extracts the timestamp of the message from the data received from the webhook.
  """
  def get_message_timestamp(data) do
    data = data["entry"]
    |> List.first()
    |> Map.get("changes")
    |> List.first()
    |> Map.get("value")

    if Map.has_key?(data, "messages") do
      data["messages"]
      |> List.first()
      |> Map.get("timestamp")
    else
      nil
    end
  end

  @doc """
  Extracts the response of the interactive message from the data received from the webhook.
  """
  def get_interactive_response(data) do
    data = data["entry"]
    |> List.first()
    |> Map.get("changes")
    |> List.first()
    |> Map.get("value")

    if Map.has_key?(data, "messages") do
      data["messages"]
      |> List.first()
      |> Map.get("interactive")
    else
      nil
    end
  end

  @doc """
  Extracts the location of the sender from the data received from the webhook.
  """
  def get_location(data) do
    data = data["entry"]
    |> List.first()
    |> Map.get("changes")
    |> List.first()
    |> Map.get("value")

    if Map.has_key?(data, "messages") do
      data["messages"]
      |> List.first()
      |> Map.get("location")
    else
      nil
    end
  end

  @doc """
  Extracts the image of the sender from the data received from the webhook.
  """
  def get_image(data) do
    data = data["entry"]
    |> List.first()
    |> Map.get("changes")
    |> List.first()
    |> Map.get("value")

    if Map.has_key?(data, "messages") do
      data["messages"]
      |> List.first()
      |> Map.get("image")
    else
      nil
    end
  end

  @doc """
  Extracts the document of the sender from the data received from the webhook.
  """
  def get_document(data) do
    data = data["entry"]
    |> List.first()
    |> Map.get("changes")
    |> List.first()
    |> Map.get("value")

    if Map.has_key?(data, "messages") do
      data["messages"]
      |> List.first()
      |> Map.get("document")
    else
      nil
    end
  end

  @doc """
  Extracts the audio of the sender from the data received from the webhook.
  """
  def get_audio(data) do
    data = data["entry"]
    |> List.first()
    |> Map.get("changes")
    |> List.first()
    |> Map.get("value")

    if Map.has_key?(data, "messages") do
      data["messages"]
      |> List.first()
      |> Map.get("audio")
    else
      nil
    end
  end

  @doc """
  Extracts the video of the sender from the data received from the webhook.
  """
  def get_video(data) do
    data = data["entry"]
    |> List.first()
    |> Map.get("changes")
    |> List.first()
    |> Map.get("value")

    if Map.has_key?(data, "messages") do
      data["messages"]
      |> List.first()
      |> Map.get("video")
    else
      nil
    end
  end

  @doc """
  Gets the type of the message sent by the sender from the data received from the webhook.
  """
  def get_message_type(data) do
    data = data["entry"]
    |> List.first()
    |> Map.get("changes")
    |> List.first()
    |> Map.get("value")

    if Map.has_key?(data, "messages") do
      data["messages"]
      |> List.first()
      |> Map.get("type")
    else
      nil
    end
  end

  @doc """
  Extracts the delivery status of the message from the data received from the webhook.
  """
  def get_delivery(data) do
    data = data["entry"]
    |> List.first()
    |> Map.get("changes")
    |> List.first()
    |> Map.get("value")

    if Map.has_key?(data, "statuses") do
      data["statuses"]
      |> List.first()
      |> Map.get("status")
    else
      nil
    end
  end

  @doc """
  Helper function to check if the field changed in the data received from the webhook.
  """
  def changed_field(data) do
    data["entry"]
    |> List.first()
    |> Map.get("changes")
    |> List.first()
    |> Map.get("field")
  end

  @doc """
  Extracts the author of the message from the data received from the webhook.
  """
  def get_author(data) do
    try do
      data["entry"]
      |> List.first()
      |> Map.get("changes")
      |> List.first()
      |> Map.get("value")
      |> Map.get("messages")
      |> List.first()
      |> Map.get("from")
    rescue
      _ -> nil
    end
  end
end
