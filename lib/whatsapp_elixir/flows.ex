defmodule WhatsappElixir.Flows do
  @moduledoc """
  Module for managing WhatsApp Flows including creation, publishing, updating, and lifecycle management.

  ## Key Functions

  - `create_flow/2`: Create a new Flow with optional publishing
  - `update_flow_metadata/3`: Update Flow name, categories, or endpoint
  - `update_flow_json/3`: Update Flow's JSON content via file upload
  - `publish_flow/2`: Publish a Flow to make it available for customers
  - `deprecate_flow/2`: Mark a published Flow as deprecated
  - `delete_flow/2`: Delete a Flow (only available for DRAFT status)
  - `get_flows/2`: List all Flows for a WhatsApp Business Account
  - `get_flow/2`: Retrieve details of a specific Flow
  - `get_flow_assets/2`: List all assets attached to a Flow
  - `generate_preview/2`: Generate a web preview URL for Flow visualization
  - `migrate_flows/3`: Migrate Flows between WhatsApp Business Accounts

  ## Flows Overview

  WhatsApp Flows are interactive experiences that allow businesses to create structured
  conversations with customers. Flows can be used for various purposes including:

  - Sign up and sign in processes
  - Appointment booking
  - Lead generation
  - Customer support
  - Surveys and feedback collection

  ### Flow Categories

  - `SIGN_UP`: User registration flows
  - `SIGN_IN`: User authentication flows
  - `APPOINTMENT_BOOKING`: Scheduling and booking flows
  - `LEAD_GENERATION`: Lead capture flows
  - `CONTACT_US`: Contact and inquiry flows
  - `CUSTOMER_SUPPORT`: Support and help flows
  - `SURVEY`: Survey and feedback flows
  - `OTHER`: General purpose flows

  ### Flow Status

  - `DRAFT`: Flow is under development, can be tested with draft mode
  - `PUBLISHED`: Flow is live and can be sent to customers
  - `DEPRECATED`: Flow is retired and cannot be sent or opened
  - `BLOCKED`: Flow endpoint is unhealthy, cannot be sent or opened
  - `THROTTLED`: Flow endpoint has issues, limited to 10 messages per hour

  ## Prerequisites

  To use the Flows API, you need:
  - Message templates (view and manage) permissions
  - Phone Numbers (view and manage) permissions
  - Verified business with high message quality
  - Meta application connected to Flows with endpoints

  For complete details, see the [WhatsApp Flows API documentation](https://developers.facebook.com/docs/whatsapp/flows/reference/).
  """

  require Logger
  alias WhatsappElixir.HTTP

  @valid_categories [
    "SIGN_UP",
    "SIGN_IN",
    "APPOINTMENT_BOOKING",
    "LEAD_GENERATION",
    "CONTACT_US",
    "CUSTOMER_SUPPORT",
    "SURVEY",
    "OTHER"
  ]

  @doc """
  Creates a new Flow.

  ## Parameters

    - `flow_data`: A map containing the following keys:
      - `:name` (string, required): Flow name
      - `:categories` (list, required): List of Flow categories (at least one required)
      - `:flow_json` (string, optional): Flow's JSON encoded as string
      - `:publish` (boolean, optional): Whether to publish the Flow immediately (requires flow_json)
      - `:clone_flow_id` (string, optional): ID of source Flow to clone
      - `:endpoint_uri` (string, optional): URL of the WhatsApp Flow Endpoint (for Flow JSON v3.0+)
    - `custom_config` (keyword, optional): Custom configuration for the HTTP request

  ## Examples

      # Create a simple draft Flow
      iex> flow_data = %{
      ...>   name: "Customer Survey",
      ...>   categories: ["SURVEY", "CUSTOMER_SUPPORT"]
      ...> }
      iex> WhatsappElixir.Flows.create_flow(flow_data)
      {:ok, %{"id" => "flow123", "success" => true, "validation_errors" => []}}

      # Create and publish a Flow with JSON content
      iex> flow_data = %{
      ...>   name: "Lead Generation Form",
      ...>   categories: ["LEAD_GENERATION"],
      ...>   flow_json: "{\"version\":\"5.0\",\"screens\":[...]}",
      ...>   publish: true,
      ...>   endpoint_uri: "https://example.com/webhook"
      ...> }
      iex> WhatsappElixir.Flows.create_flow(flow_data)
      {:ok, %{"id" => "flow456", "success" => true}}

  ## Returns

    - `{:ok, response}` on success with Flow ID and validation errors if any
    - `{:error, response}` on failure

  ## Validation

    - Raises `ArgumentError` if required fields (`name`, `categories`) are missing
    - Raises `ArgumentError` if categories contain invalid values
    - Raises `ArgumentError` if `publish` is true but `flow_json` is not provided
  """
  def create_flow(flow_data, custom_config \\ []) do
    # Validate required fields
    validate_required_fields(flow_data, [:name, :categories])

    # Validate categories
    validate_categories(Map.get(flow_data, :categories))

    # Validate publish requirements
    if Map.get(flow_data, :publish, false) and not Map.has_key?(flow_data, :flow_json) do
      raise ArgumentError, "flow_json must be provided when publish is true"
    end

    body =
      Map.take(flow_data, [
        :name,
        :categories,
        :flow_json,
        :publish,
        :clone_flow_id,
        :endpoint_uri
      ])

    Logger.info("Creating Flow: #{Map.get(flow_data, :name)}")

    # POST {BASE-URL}/{WABA-ID}/flows
    post_to_waba("flows", body, custom_config)
  end

  @doc """
  Updates a Flow's metadata (name, categories, endpoint_uri, application_id).

  ## Parameters

    - `flow_id` (string): ID of the Flow to update
    - `update_data` (map): Data to update containing:
      - `:name` (string, optional): New Flow name
      - `:categories` (list, optional): New Flow categories (at least one required if provided)
      - `:endpoint_uri` (string, optional): New endpoint URI (for Flow JSON v3.0+)
      - `:application_id` (string, optional): Meta application ID to connect to the Flow
    - `custom_config` (keyword, optional): Custom configuration for the HTTP request

  ## Examples

      # Update Flow name
      iex> WhatsappElixir.Flows.update_flow_metadata("flow123", %{name: "Updated Survey"})
      {:ok, %{"success" => true}}

  ## Returns

    - `{:ok, response}` on success
    - `{:error, response}` on failure
  """
  def update_flow_metadata(flow_id, update_data, custom_config \\ []) do
    # Validate categories if provided
    if Map.has_key?(update_data, :categories) do
      validate_categories(Map.get(update_data, :categories))
    end

    body =
      Map.take(update_data, [
        :name,
        :categories,
        :endpoint_uri,
        :application_id
      ])

    Logger.info("Updating Flow metadata: #{flow_id}")

    # POST {BASE-URL}/{FLOW-ID}
    post_to_flow(flow_id, body, custom_config)
  end

  @doc """
  Updates a Flow's JSON content by uploading a JSON file.

  ## Parameters

    - `flow_id` (string): ID of the Flow to update
    - `json_file_path` (string): Path to the JSON file containing Flow content
    - `custom_config` (keyword, optional): Custom configuration for the HTTP request

  ## Examples

      iex> WhatsappElixir.Flows.update_flow_json("flow123", "/path/to/flow.json")
      {:ok, %{"success" => true, "validation_errors" => []}}

  ## Returns

    - `{:ok, response}` on success with validation errors if any
    - `{:error, response}` on failure

  ## Notes

    - The JSON file must be valid Flow JSON format
    - File size is limited to 10 MB
    - The file is uploaded as multipart form data
  """
  def update_flow_json(flow_id, json_file_path, custom_config \\ []) do
    unless File.exists?(json_file_path) do
      raise ArgumentError, "JSON file not found: #{json_file_path}"
    end

    filename = Path.basename(json_file_path)
    file_content = File.read!(json_file_path)

    multipart_body =
      Multipart.new()
      |> Multipart.add_part(Multipart.Part.text_field("flow.json", "name"))
      |> Multipart.add_part(Multipart.Part.text_field("FLOW_JSON", "asset_type"))
      |> Multipart.add_part(
        Multipart.Part.file_content_field(filename, file_content, :file, filename: filename)
      )

    Logger.info("Updating Flow JSON for Flow: #{flow_id}")

    # POST {BASE-URL}/{FLOW_ID}/assets
    post_multipart_to_flow("#{flow_id}/assets", multipart_body, custom_config)
  end

  @doc """
  Publishes a Flow, making it available to send to customers.

  ## Parameters

    - `flow_id` (string): ID of the Flow to publish
    - `custom_config` (keyword, optional): Custom configuration for the HTTP request

  ## Examples

      iex> WhatsappElixir.Flows.publish_flow("flow123")
      {:ok, %{"success" => true}}

  ## Returns

    - `{:ok, response}` on success
    - `{:error, response}` on failure
  """
  def publish_flow(flow_id, custom_config \\ []) do
    Logger.info("Publishing Flow: #{flow_id}")

    # POST {BASE-URL}/{FLOW-ID}/publish
    post_to_flow("#{flow_id}/publish", %{}, custom_config)
  end

  @doc """
  Deprecates a published Flow, preventing it from being sent or opened.

  ## Parameters

    - `flow_id` (string): ID of the Flow to deprecate
    - `custom_config` (keyword, optional): Custom configuration for the HTTP request

  ## Examples

      iex> WhatsappElixir.Flows.deprecate_flow("flow123")
      {:ok, %{"success" => true}}

  ## Returns

    - `{:ok, response}` on success
    - `{:error, response}` on failure
  """
  def deprecate_flow(flow_id, custom_config \\ []) do
    Logger.info("Deprecating Flow: #{flow_id}")

    # POST {BASE-URL}/{FLOW-ID}/deprecate
    post_to_flow("#{flow_id}/deprecate", %{}, custom_config)
  end

  @doc """
  Deletes a Flow. Only Flows in DRAFT status can be deleted.

  ## Parameters

    - `flow_id` (string): ID of the Flow to delete
    - `custom_config` (keyword, optional): Custom configuration for the HTTP request

  ## Examples

      iex> WhatsappElixir.Flows.delete_flow("flow123")
      {:ok, %{"success" => true}}

  ## Returns

    - `{:ok, response}` on success
    - `{:error, response}` on failure
  """
  def delete_flow(flow_id, custom_config \\ []) do
    Logger.info("Deleting Flow: #{flow_id}")

    # DELETE {BASE-URL}/{FLOW-ID}
    delete_flow_endpoint(flow_id, custom_config)
  end

  @doc """
  Lists all Flows for a WhatsApp Business Account.

  ## Parameters

    - `fields` (string, optional): Comma-separated list of fields to include in response
    - `custom_config` (keyword, optional): Custom configuration for the HTTP request

  ## Examples

      # List all Flows with default fields
      iex> WhatsappElixir.Flows.get_flows()
      {:ok, %{
        "data" => [
          %{"id" => "flow1", "name" => "Survey", "status" => "PUBLISHED", "categories" => ["SURVEY"]},
          %{"id" => "flow2", "name" => "Lead Gen", "status" => "DRAFT", "categories" => ["LEAD_GENERATION"]}
        ],
        "paging" => %{"cursors" => %{"before" => "...", "after" => "..."}}
      }}

  ## Returns

    - `{:ok, response}` containing data array and paging information
    - `{:error, response}` on failure
  """
  def get_flows(fields \\ "", custom_config \\ []) do
    params =
      if fields != "" do
        %{"fields" => fields}
      else
        %{}
      end

    Logger.info("Retrieving Flows list")

    # GET {BASE-URL}/{WABA-ID}/flows
    get_from_waba("flows", params, custom_config)
  end

  @doc """
  Retrieves details of a specific Flow.

  ## Parameters

    - `flow_id` (string): ID of the Flow to retrieve
    - `fields` (string, optional): Comma-separated list of fields to include
    - `phone_number_id` (string, optional): Phone number ID for health status check
    - `custom_config` (keyword, optional): Custom configuration for the HTTP request

  ## Examples

      # Get Flow with default fields
      iex> WhatsappElixir.Flows.get_flow("flow123")
      {:ok, %{
        "id" => "flow123",
        "name" => "Customer Survey",
        "status" => "PUBLISHED",
        "categories" => ["SURVEY"],
        "validation_errors" => []
      }}

  ## Returns

    - `{:ok, response}` containing Flow details
    - `{:error, response}` on failure
  """
  def get_flow(flow_id, fields \\ "", phone_number_id \\ nil, custom_config \\ []) do
    params =
      cond do
        phone_number_id != nil ->
          health_field = "health_status.phone_number(#{phone_number_id})"
          current_fields = if fields != "", do: "#{fields},#{health_field}", else: health_field
          %{"fields" => current_fields}

        fields != "" ->
          %{"fields" => fields}

        true ->
          %{}
      end

    Logger.info("Retrieving Flow details: #{flow_id}")

    # GET {BASE-URL}/{FLOW-ID}
    get_from_flow(flow_id, params, custom_config)
  end

  @doc """
  Lists all assets attached to a specific Flow.

  ## Parameters

    - `flow_id` (string): ID of the Flow
    - `custom_config` (keyword, optional): Custom configuration for the HTTP request

  ## Examples

      iex> WhatsappElixir.Flows.get_flow_assets("flow123")
      {:ok, %{
        "data" => [
          %{
            "name" => "flow.json",
            "asset_type" => "FLOW_JSON",
            "download_url" => "https://scontent.xx.fbcdn.net/..."
          }
        ]
      }}

  ## Returns

    - `{:ok, response}` containing assets data and paging information
    - `{:error, response}` on failure
  """
  def get_flow_assets(flow_id, custom_config \\ []) do
    Logger.info("Retrieving Flow assets: #{flow_id}")

    # GET {BASE-URL}/{FLOW-ID}/assets
    get_from_flow("#{flow_id}/assets", %{}, custom_config)
  end

  @doc """
  Generates a web preview URL for visualizing and testing a Flow.

  ## Parameters

    - `flow_id` (string): ID of the Flow
    - `invalidate_existing` (boolean, optional): Whether to invalidate existing preview URL
    - `custom_config` (keyword, optional): Custom configuration for the HTTP request

  ## Examples

      # Generate new preview URL
      iex> WhatsappElixir.Flows.generate_preview("flow123")
      {:ok, %{
        "preview" => %{
          "preview_url" => "https://business.facebook.com/wa/manage/flows/123/preview/?token=abc...",
          "expires_at" => "2023-05-21T11:18:09+0000"
        },
        "id" => "flow123"
      }}

  ## Returns

    - `{:ok, response}` containing preview URL and expiration time
    - `{:error, response}` on failure
  """
  def generate_preview(flow_id, invalidate_existing \\ false, custom_config \\ []) do
    fields = "preview.invalidate(#{invalidate_existing})"
    params = %{"fields" => fields}

    Logger.info("Generating preview URL for Flow: #{flow_id}")

    # GET {BASE-URL}/{FLOW-ID}?fields=preview.invalidate(false)
    get_from_flow(flow_id, params, custom_config)
  end

  @doc """
  Migrates Flows from one WhatsApp Business Account to another.

  ## Parameters

    - `destination_waba_id` (string): Destination WABA ID
    - `source_waba_id` (string): Source WABA ID
    - `source_flow_names` (list, optional): Specific Flow names to migrate (max 100)
    - `custom_config` (keyword, optional): Custom configuration for the HTTP request

  ## Examples

      # Migrate all Flows
      iex> WhatsappElixir.Flows.migrate_flows("dest_waba", "source_waba")
      {:ok, %{
        "migrated_flows" => [
          %{"source_name" => "survey", "source_id" => "123", "migrated_id" => "456"}
        ],
        "failed_flows" => []
      }}

      # Migrate specific Flows
      iex> WhatsappElixir.Flows.migrate_flows("dest_waba", "source_waba", ["survey", "lead-gen"])
      {:ok, %{"migrated_flows" => [...], "failed_flows" => [...]}}

  ## Returns

    - `{:ok, response}` containing migrated and failed Flows
    - `{:error, response}` on failure
  """
  def migrate_flows(destination_waba_id, source_waba_id, source_flow_names \\ nil, custom_config \\ []) do
    Logger.info("Migrating Flows from #{source_waba_id} to #{destination_waba_id}")

    # POST {BASE-URL}/{DESTINATION_WABA_ID}/migrate_flows?source_waba_id={SOURCE_WABA_ID}&source_flow_names={SOURCE_FLOW_NAMES}
    post_migrate_flows(destination_waba_id, source_waba_id, source_flow_names, custom_config)
  end

  # Private HTTP helper methods that match the Flows API structure

  # POST to WABA endpoint: {BASE-URL}/{WABA-ID}/endpoint
  defp post_to_waba(endpoint, body, custom_config) do
    config_opts = HTTP.config(custom_config)
    waba_id = get_waba_id(config_opts)
    token = get_token(config_opts)

    url = build_base_url(config_opts) <> "/#{waba_id}/#{endpoint}"

    case Req.post(url, body: Jason.encode!(body), headers: headers(token)) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, Jason.decode!(body)}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("[WHATSAPP_ELIXIR] Flows API request failed with status #{status}: #{inspect(body)}")
        {:error, Jason.decode!(body)}

      {:error, reason} ->
        Logger.error("[WHATSAPP_ELIXIR] Flows API request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # POST to Flow endpoint: {BASE-URL}/{FLOW-ID} or {BASE-URL}/{FLOW-ID}/action
  defp post_to_flow(endpoint, body, custom_config) do
    config_opts = HTTP.config(custom_config)
    token = get_token(config_opts)

    url = build_base_url(config_opts) <> "/#{endpoint}"

    case Req.post(url, body: Jason.encode!(body), headers: headers(token)) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, Jason.decode!(body)}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("[WHATSAPP_ELIXIR] Flows API request failed with status #{status}: #{inspect(body)}")
        {:error, Jason.decode!(body)}

      {:error, reason} ->
        Logger.error("[WHATSAPP_ELIXIR] Flows API request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # POST multipart to Flow endpoint: {BASE-URL}/{FLOW-ID}/assets
  defp post_multipart_to_flow(endpoint, multipart_body, custom_config) do
    config_opts = HTTP.config(custom_config)
    token = get_token(config_opts)

    url = build_base_url(config_opts) <> "/#{endpoint}"
    content_type = Multipart.content_type(multipart_body, "multipart/form-data")
    body_stream = Multipart.body_stream(multipart_body)

    case Req.post(url, body: body_stream, headers: headers(token, content_type)) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, Jason.decode!(body)}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("[WHATSAPP_ELIXIR] Flows API multipart request failed with status #{status}: #{inspect(body)}")
        {:error, Jason.decode!(body)}

      {:error, reason} ->
        Logger.error("[WHATSAPP_ELIXIR] Flows API multipart request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # GET from WABA endpoint: {BASE-URL}/{WABA-ID}/flows
  defp get_from_waba(endpoint, params, custom_config) do
    config_opts = HTTP.config(custom_config)
    waba_id = get_waba_id(config_opts)
    token = get_token(config_opts)

    base_url = build_base_url(config_opts) <> "/#{waba_id}/#{endpoint}"
    url = build_url_with_params(base_url, params)

    case Req.get(url, headers: headers(token)) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, Jason.decode!(body)}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("[WHATSAPP_ELIXIR] Flows API request failed with status #{status}: #{inspect(body)}")
        {:error, body}

      {:error, reason} ->
        Logger.error("[WHATSAPP_ELIXIR] Flows API request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # GET from Flow endpoint: {BASE-URL}/{FLOW-ID}
  defp get_from_flow(endpoint, params, custom_config) do
    config_opts = HTTP.config(custom_config)
    token = get_token(config_opts)

    base_url = build_base_url(config_opts) <> "/#{endpoint}"
    url = build_url_with_params(base_url, params)

    case Req.get(url, headers: headers(token)) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, Jason.decode!(body)}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("[WHATSAPP_ELIXIR] Flows API request failed with status #{status}: #{inspect(body)}")
        {:error, body}

      {:error, reason} ->
        Logger.error("[WHATSAPP_ELIXIR] Flows API request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # DELETE Flow endpoint: {BASE-URL}/{FLOW-ID}
  defp delete_flow_endpoint(flow_id, custom_config) do
    config_opts = HTTP.config(custom_config)
    token = get_token(config_opts)

    url = build_base_url(config_opts) <> "/#{flow_id}"

    case Req.delete(url, headers: headers(token)) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, Jason.decode!(body)}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("[WHATSAPP_ELIXIR] Flows API DELETE failed with status #{status}: #{inspect(body)}")
        {:error, body}

      {:error, reason} ->
        Logger.error("[WHATSAPP_ELIXIR] Flows API DELETE request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # Special POST for migration: {BASE-URL}/{DESTINATION_WABA_ID}/migrate_flows?source_waba_id=...
  defp post_migrate_flows(destination_waba_id, source_waba_id, source_flow_names, custom_config) do
    config_opts = HTTP.config(custom_config)
    token = get_token(config_opts)

    params = %{"source_waba_id" => source_waba_id}
    params = if source_flow_names, do: Map.put(params, "source_flow_names", source_flow_names), else: params

    base_url = build_base_url(config_opts) <> "/#{destination_waba_id}/migrate_flows"
    url = build_url_with_params(base_url, params)

    case Req.post(url, body: "", headers: headers(token)) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, Jason.decode!(body)}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("[WHATSAPP_ELIXIR] Flows migration failed with status #{status}: #{inspect(body)}")
        {:error, Jason.decode!(body)}

      {:error, reason} ->
        Logger.error("[WHATSAPP_ELIXIR] Flows migration request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # Helper functions for URL building and configuration

  defp build_base_url(config_opts) do
    base_url = Keyword.get(config_opts, :base_url, "https://graph.facebook.com")
    api_version = Keyword.get(config_opts, :api_version, "v18.0")
    "#{base_url}/#{api_version}"
  end

  defp build_url_with_params(base_url, params) when map_size(params) == 0, do: base_url
  defp build_url_with_params(base_url, params) do
    query_string = URI.encode_query(params)
    "#{base_url}?#{query_string}"
  end

  defp get_waba_id(config_opts) do
    waba_id = Keyword.get(config_opts, :phone_number_id)
    if waba_id in [nil, ""] do
      raise ArgumentError, "WABA ID (phone_number_id) must be provided for Flows API"
    end
    waba_id
  end

  defp get_token(config_opts) do
    token = Keyword.get(config_opts, :token)
    if token in [nil, ""] do
      raise ArgumentError, "Access token must be provided for Flows API"
    end
    token
  end

  defp headers(token, content_type \\ "application/json") do
    [
      {"Content-Type", content_type},
      {"Authorization", "Bearer #{token}"}
    ]
  end

  # Validation helper functions

  defp validate_required_fields(data, required_fields) do
    Enum.each(required_fields, fn field ->
      if Map.get(data, field) in [nil, "", []] do
        raise ArgumentError, "#{Atom.to_string(field)} must be provided"
      end
    end)
  end

  defp validate_categories(categories) when is_list(categories) do
    if Enum.empty?(categories) do
      raise ArgumentError, "At least one category must be provided"
    end

    invalid_categories = Enum.reject(categories, &(&1 in @valid_categories))

    unless Enum.empty?(invalid_categories) do
      valid_list = Enum.join(@valid_categories, ", ")
      invalid_list = Enum.join(invalid_categories, ", ")
      raise ArgumentError,
        "Invalid categories: #{invalid_list}. Valid categories are: #{valid_list}"
    end
  end

  defp validate_categories(_), do: raise(ArgumentError, "Categories must be a list")
end
