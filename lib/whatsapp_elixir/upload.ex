defmodule WhatsappElixir.Upload do

  @moduledoc """
    Handles CRUD operations for media using the WhatsApp Cloud API.

    This module provides functionalities for uploading, querying, deleting,
    and downloading media files associated with your WhatsApp Business account.

    ### Endpoints
    The following endpoints are used for media management:
    - **POST /PHONE_NUMBER_ID/media**: Upload media.
    - **GET /MEDIA_ID**: Retrieve the URL for a specific media.
    - **DELETE /MEDIA_ID**: Delete a specific media.
    - **GET /MEDIA_URL**: Download media from a media URL.

    ### Supported Media Types
    Refer to the official documentation for details on supported media types, size limits,
    and other constraints:
    [WhatsApp Cloud API - Media Reference](https://developers.facebook.com/docs/whatsapp/cloud-api/reference/media/#supported-media-types)
  """

  require Logger
  alias WhatsappElixir.HTTP


  @endpoint "media"


  @doc """
  Uploads media to the WhatsApp Cloud API.

  ## Parameters:
    - `media_path` (string): Path to the media file to upload.
    - `mime_type` (string): MIME type of the media (e.g., "image/png").
    - `custom_config` (optional list): Custom configuration for the HTTP request.

  ## Returns:
    - `{:ok, response}` on success.
    - `{:error, response}` on failure.

  ## Example:
  ```elixir
  Upload.upload_media("new.png", "image/png")
  """

  def upload_media(media_path, mime_type, custom_config \\ []) do
    filename = Path.basename(media_path)
    file_content = File.read!(media_path)

    multipart_body =
      Multipart.new()
      |> Multipart.add_part(Multipart.Part.text_field(
        "whatsapp", "messaging_product"
      ))
      |> Multipart.add_part(Multipart.Part.text_field("type", mime_type))
      |>  Multipart.add_part(
        Multipart.Part.file_content_field(filename, file_content, :file, filename: filename)
      )


    Logger.info("Preparing to upload media from #{media_path}")

    # Define content type for multipart form data
    content_type = "multipart/form-data"
    include_phone_number_id = true

    # Call the HTTP post method, passing the multipart body and other params
    case HTTP.post(@endpoint, multipart_body, custom_config, include_phone_number_id, content_type) do
      {:ok, response} ->
        Logger.info("Media uploaded successfully: #{inspect(response)}")
        {:ok, response}

      {:error, response} ->
        Logger.error("Failed to upload media: #{inspect(response)}")
        {:error, response}
    end
  end

  def delete_media(media_id, custom_configs \\ []) do
    Logger.info("Deleting media with ID: #{media_id}")

    case HTTP.delete(media_id, %{}, custom_configs, true) do
      {:ok, response} ->
        Logger.info("Media #{media_id} deleted successfully")
        {:ok, response}

      {:error, reason} ->
        Logger.error("Error deleting media #{media_id}: #{inspect(reason)}")
        {:error, reason}
    end
  end
  @doc """
  Queries the URL of a media item using its media ID.

  ## Parameters:
    - `media_id` (string): ID of the media to query.
    - `custom_config` (optional list): Custom configuration for the HTTP request.

  ## Returns:
    - `{:ok, url}` on success.
    - `{:error, reason}` on failure.

  ## Example:
  ```elixir
  Upload.query_media_url("575674161631216")
  """
  def query_media(media_id, custom_configs \\ []) do
    Logger.info("Querying media URL for ID: #{media_id}")

    case HTTP.get(media_id, %{}, custom_configs, true) do
      {:ok, %{"url" => url}} ->
        {:ok, url}

      {:error, reason} ->
        {:error, reason}
    end

  end

 @doc """
Downloads media from a given `media_url` and saves it to the specified file path.

## Arguments
- `media_url` (string): The URL of the media to be downloaded.
- `mime_type` (string): The MIME type of the media (e.g., `"image/png"`, `"video/mp4"`).
- `file_path` (string, optional): The file path to save the media. Do not include the file extension. Defaults to `"temp"`.

## Returns
- `{:ok, file_path}` on successful download.
- `{:error, reason}` if the download fails.

## Notes
The `media_url` expires after 5 minutes. To download the file after the URL has expired, you will need to request a new URL.
"""
def download_media(media_url, mime_type, file_path \\ "temp", custom_config \\ []) do
  extension =
    case String.split(mime_type, "/") do
      [_type, ext] -> ext
      _ -> raise ArgumentError, "Invalid MIME type: #{mime_type}"
    end

  save_path = "#{file_path}.#{extension}"

  Logger.info("Downloading media from URL: #{media_url}")

  case HTTP.get_url(media_url, custom_config) do
    {:ok, body} ->
      # Save the binary data to the file
      File.write(save_path, body)
      Logger.info("Media downloaded successfully to #{save_path}")
      {:ok, save_path}

 
    {:error, reason} ->
      Logger.error("Failed to download media: #{inspect(reason)}")
      {:error, reason}
  end


end

end
