defmodule WhatsappElixir.Media do
   @moduledoc """
  Send different Media  to WhatsApp users.
  """

require Logger
alias WhatsappElixir.HTTP


@endpoint "messages"


@doc """
Sends a location message to a WhatsApp user.

## Args
  - lat: Latitude of the location
  - long: Longitude of the location
  - name: Name of the location
  - address: Address of the location
  - recipient_id: Phone number of the user with country code without +

## Example

    iex> WhatsappElixir.send_location("-23.564", "-46.654", "My Location", "Rua dois, 123", "5511999999999")
    {:ok, %{"success" => true}}
"""
def send_location(lat, long, name, address, recipient_id, custom_config \\ []) do
  data = %{
    messaging_product: "whatsapp",
    to: recipient_id,
    type: "location",
    location: %{
      latitude: lat,
      longitude: long,
      name: name,
      address: address
    }
  }

  Logger.info("Sending location to #{recipient_id}")
  case HTTP.post(@endpoint, data, custom_config ) do
    {:ok, response} ->
      Logger.info("Location sent to #{recipient_id}")
      response
    {:error, reason} ->
      Logger.error("Failed to send location to #{recipient_id}: #{inspect(reason)}")
      {:error, reason}
  end
end

@doc """
Sends an image message to a WhatsApp user.

## Args
  - image: Image id or link of the image
  - recipient_id: Phone number of the user with country code without +
  - recipient_type: Type of the recipient, either individual or group (default is "individual")
  - caption: Caption of the image (default is "")
  - link: Whether to send an image id or an image link, True means that the image is a link, False means that the image is an id (default is true)

## Example

    iex> WhatsappElixir.send_image("https://i.imgur.com/Fh7XVYY.jpeg", "5511999999999")
    {:ok, %{"success" => true}}
"""
def send_image(image, recipient_id, custom_config \\ [], recipient_type \\ "individual", caption \\ "", link \\ true) do
  data = %{
    messaging_product: "whatsapp",
    recipient_type: recipient_type,
    to: recipient_id,
    type: "image",
    image: (if link, do: %{link: image, caption: caption}, else: %{id: image, caption: caption})
  }

  Logger.info("Sending image to #{recipient_id}")
  case HTTP.post(@endpoint, data, custom_config) do
    {:ok, response} ->
      Logger.info("Image sent to #{recipient_id}")
      response
    {:error, reason} ->
      Logger.error("Failed to send image to #{recipient_id}: #{inspect(reason)}")
      {:error, reason}
  end
end

@doc """
Sends a sticker message to a WhatsApp user.

## Args
  - sticker: Sticker id or link of the sticker
  - recipient_id: Phone number of the user with country code without +
  - recipient_type: Type of the recipient, either individual or group (default is "individual")
  - link: Whether to send a sticker id or a sticker link, True means that the sticker is a link, False means that the sticker is an id (default is true)

## Example

    iex> WhatsappElixir.send_sticker("170511049062862", "5511999999999", "individual", false)
    {:ok, %{"success" => true}}
"""
def send_sticker(sticker, recipient_id, custom_config \\ [],  recipient_type \\ "individual", link \\ true) do
  data = %{
    messaging_product: "whatsapp",
    recipient_type: recipient_type,
    to: recipient_id,
    type: "sticker",
    sticker: (if link, do: %{link: sticker}, else: %{id: sticker})
  }

  Logger.info("Sending sticker to #{recipient_id}")
  case HTTP.post(@endpoint, data, custom_config) do
    {:ok, response} ->
      Logger.info("Sticker sent to #{recipient_id}")
      response
    {:error, reason} ->
      Logger.error("Failed to send sticker to #{recipient_id}: #{inspect(reason)}")
      {:error, reason}
  end
end

@doc """
Sends an audio message to a WhatsApp user.

## Args
  - audio: Audio id or link of the audio
  - recipient_id: Phone number of the user with country code without +
  - link: Whether to send an audio id or an audio link, True means that the audio is a link, False means that the audio is an id (default is true)

## Example

    iex> WhatsappElixir.send_audio("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3", "5511999999999")
    {:ok, %{"success" => true}}
"""
def send_audio(audio, recipient_id, custom_config \\ [],   link \\ true) do
  data = %{
    messaging_product: "whatsapp",
    to: recipient_id,
    type: "audio",
    audio: (if link, do: %{link: audio}, else: %{id: audio})
  }

  Logger.info("Sending audio to #{recipient_id}")
  case HTTP.post(@endpoint, data, custom_config) do
    {:ok, response} ->
      Logger.info("Audio sent to #{recipient_id}")
      response
    {:error, reason} ->
      Logger.error("Failed to send audio to #{recipient_id}: #{inspect(reason)}")
      {:error, reason}
  end
end

@doc """
Sends a video message to a WhatsApp user.

## Args
  - video: Video id or link of the video
  - recipient_id: Phone number of the user with country code without +
  - caption: Caption of the video (default is "")
  - link: Whether to send a video id or a video link, True means that the video is a link, False means that the video is an id (default is true)

## Example

    iex> WhatsappElixir.send_video("https://www.youtube.com/watch?v=dQw4w9WgXcQ", "5511999999999")
    {:ok, %{"success" => true}}
"""
def send_video(video, recipient_id, custom_config \\ [],  caption \\ "", link \\ true) do
  data = %{
    messaging_product: "whatsapp",
    to: recipient_id,
    type: "video",
    video: (if link, do: %{link: video, caption: caption}, else: %{id: video, caption: caption})
  }

  Logger.info("Sending video to #{recipient_id}")
  case HTTP.post(@endpoint, data, custom_config) do
    {:ok, response} ->
      Logger.info("Video sent to #{recipient_id}")
      response
    {:error, reason} ->
      Logger.error("Failed to send video to #{recipient_id}: #{inspect(reason)}")
      {:error, reason}
  end
end

@doc """
Sends a document message to a WhatsApp user.

## Args
  - document: Document id or link of the document
  - recipient_id: Phone number of the user with country code without +
  - caption: Caption of the document (default is "")
  - link: Whether to send a document id or a document link, True means that the document is a link, False means that the document is an id (default is true)
  - filename: Document filename, with extension. The WhatsApp client will use an appropriate file type icon based on the extension (optional)

## Example

    iex> WhatsappElixir.Media.send_document("https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf", "5511999999999")
    {:ok, %{"success" => true}}
"""
def send_document(document, recipient_id, custom_config \\ [], caption \\ "",  link \\ true , filename \\ "") do
  data = %{
    messaging_product: "whatsapp",
    to: recipient_id,
    type: "document",
    document: (if link, do: %{link: document, caption: caption, filename: filename}, else: %{id: document, caption: caption, filename: filename})
  }

  Logger.info("Sending document to #{recipient_id}")
  case HTTP.post(@endpoint, data, custom_config) do
    {:ok, response} ->
      Logger.info("Document sent to #{recipient_id}")
      response
    {:error, reason} ->
      Logger.error("Failed to send document to #{recipient_id}: #{inspect(reason)}")
      {:error, reason}
  end
end
end
