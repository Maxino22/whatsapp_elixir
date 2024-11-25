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
    base_url: "https://graph.facebook.com",
    api_version: "v18.0"
  ]

  @spec config(keyword()) :: keyword()
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
  def post(endpoint, body, opts \\ [], include_phone_number_id \\ true, content_type \\ "application/json") do
    config_opts = config(opts)



    # Get phone_number_id if needed
     phone_number_id = if include_phone_number_id do
        config(config_opts) |> Keyword.get(:phone_number_id)
      end

      if include_phone_number_id and (phone_number_id == "" or phone_number_id == nil) do
        raise ArgumentError, "phone_number_id must be provided"
      end

    token = config(config_opts) |> Keyword.get(:token)

    if token == ""  do
      raise ArgumentError, "Missing App Token"
    end


     # Construct URL based on whether phone_number_id is included
    url = if include_phone_number_id do
      "#{base_url(config_opts)}/#{api_version(config_opts)}/#{phone_number_id}/#{endpoint}"
    else
      "#{base_url(config_opts)}/#{api_version(config_opts)}/#{endpoint}"
    end


    if content_type == "multipart/form-data" do

      content_type = Multipart.content_type(body, content_type)
      body = Multipart.body_stream(body)

      case Req.post(url, body: body, headers: headers(token, content_type)) do
        {:ok, %Response{status: status, body: body}} when status in 200..299 ->
          {:ok, body}

        {:ok, %Response{status: status, body: body}} ->
          Logger.error("[WHATSAPP_ELIXIR] HTTP request failed with status #{status}: #{inspect(body)}")
          {:error, Jason.decode!(body)}

        {:error, reason} ->
          Logger.error("HTTP request failed: #{inspect(reason)}")
          {:error, reason}
      end

    else
      case Req.post(url, body: Jason.encode!(body), headers: headers(token, content_type)) do
        {:ok, %Response{status: status, body: body}} when status in 200..299 ->
          {:ok, body}

        {:ok, %Response{status: status, body: body}} ->
          Logger.error("[WHATSAPP_ELIXIR] HTTP request failed with status #{status}: #{inspect(body)}")
          {:error, Jason.decode!(body)}

        {:error, reason} ->
          Logger.error("HTTP request failed: #{inspect(reason)}")
          {:error, reason}
      end

    end



  end


  def get(endpoint, params \\ %{}, opts \\ [], url_overide \\ false) do
    config_opts = config(opts)
    phone_number_id = config(config_opts) |> Keyword.get(:phone_number_id)

    if phone_number_id == "" do
      raise ArgumentError, "phone_number_id must be provided"
    end

    token = config(config_opts) |> Keyword.get(:token)

    if token == "" do
      raise ArgumentError, "Missing App Token"
    end

     # Construct the base URL
  base_url_path =
    if url_overide do
      # When `url_overide` is true, directly use the `endpoint` as part of the path
      "#{base_url(config_opts)}/#{api_version(config_opts)}/#{endpoint}"
    else
      phone_number_id = config_opts |> Keyword.get(:phone_number_id)
      if phone_number_id == "" do
        raise ArgumentError, "phone_number_id must be provided"
      end

      "#{base_url(config_opts)}/#{api_version(config_opts)}/#{phone_number_id}/#{endpoint}"
    end

    # Add query params only if `url_overide` is false
    query_string = URI.encode_query(params)

    full_url = if query_string != "" do
      "#{base_url_path}?#{query_string}"
    else
      base_url_path
    end

    Logger.info("Constructed URL: #{full_url}")


    case Req.get(full_url, headers: headers(token)) do
      {:ok, %Response{status: status, body: body}} when status in 200..299 ->
        {:ok,Jason.decode!(body) }

      {:ok, %Response{status: status, body: body}} ->
        Logger.error("[WHATSAPP_ELIXIR] HTTP request failed with status #{status}: #{inspect(body)}")
        {:error, body}

      {:error, reason} ->
        Logger.error("[WHATSAPP_ELIXIR] HTTP request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end


  def get_url(url, opts \\ [], headers \\ []) do
    config_opts = config(opts)
    token = config(config_opts) |> Keyword.get(:token)

    if token == "" do
      raise ArgumentError, "Missing App Token"
    end

    # Add the Authorization header
    full_headers = [{"Authorization", "Bearer #{token}"} | headers]

    Logger.info("Making GET request to URL: #{url}")

    case Req.get(url, headers: full_headers) do
      {:ok, %Response{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %Response{status: status, body: body}} ->
        Logger.error("HTTP GET request failed with status #{status}: #{inspect(body)}")
        {:error, %{status: status, body: body}}

      {:error, reason} ->
        Logger.error("HTTP GET request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end


    @doc """
  Sends a DELETE request to the specified endpoint with the given parameters.
  """
  def delete(endpoint, params \\ %{}, opts \\ [], url_override \\ false) do
    config_opts = config(opts)
    token = config(config_opts) |> Keyword.get(:token)

    if token == "" do
      raise ArgumentError, "Missing App Token"
    end

    url =
      if url_override do
        "#{base_url(config_opts)}/#{api_version(config_opts)}/#{endpoint}"
      else
        phone_number_id = config(config_opts) |> Keyword.get(:phone_number_id)

        if phone_number_id == "" do
          raise ArgumentError, "phone_number_id must be provided"
        end

        "#{base_url(config_opts)}/#{api_version(config_opts)}/#{phone_number_id}/#{endpoint}"
      end

    query_string = URI.encode_query(params)
    full_url = if query_string != "", do: "#{url}?#{query_string}", else: url

    Logger.info("Constructed DELETE URL: #{full_url}")

    case Req.delete(full_url, headers: headers(token)) do
      {:ok, %Response{status: status, body: body}} when status in 200..299 ->
        {:ok, Jason.decode!(body)}

      {:ok, %Response{status: status, body: body}} ->
        Logger.error("[WHATSAPP_ELIXIR] HTTP DELETE failed with status #{status}: #{inspect(body)}")
        {:error, body}

      {:error, reason} ->
        Logger.error("[WHATSAPP_ELIXIR] HTTP DELETE request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end



  defp headers(token, content_type \\ "application/json") do
    [
      {"Content-Type", content_type},
      {"Authorization", "Bearer #{token}"}
    ]
  end



end
