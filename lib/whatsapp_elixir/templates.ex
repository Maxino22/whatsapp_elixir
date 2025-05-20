defmodule WhatsappElixir.Templates do
  @moduledoc """
  Module for managing WhatsApp message templates including creation, deletion, editing, and listing.

  ## Key Functions

  - `create_template/2`: Create a new message template
  - `update_template/3`: Update an existing template
  - `delete_template/2`: Delete a template
  - `get_templates/2`: List all templates for a WhatsApp Business Account

  ## Templates Overview

  Templates are pre-approved message formats for sending content through WhatsApp.
  They can be AUTHENTICATION, MARKETING, or UTILITY type and support both POSITIONAL (default)
  and NAMED parameter formatting.

  > Note: The `allow_category_change` parameter is no longer supported as WhatsApp now automatically
  > recategorizes templates based on content analysis by default.

  For complete details, see the [WhatsApp Templates documentation](https://developers.facebook.com/docs/whatsapp/business-management-api/message-templates/).
  """

  alias WhatsappElixir.HTTP

  @endpoint "message_templates"

  @doc """
  Creates a new message template.

  ## Parameters

    - `template_data`: A map containing the following keys:
      - `:name` (string, required): Template name (maximum 512 characters).
      - `:category` (string, required): Template category (`AUTHENTICATION`, `MARKETING`, `UTILITY`).
      - `:language` (string, required): Template language and locale code (e.g., "en_US").
      - `:components` (list, required): Array of template components.
      - `:parameter_format` (string, optional): The type of parameter formatting for HEADER and BODY components.
        Can be either `NAMED` or `POSITIONAL`. Defaults to `POSITIONAL` if not specified.
      - `:library_template_name` (string, optional): Exact name of the Utility Template Library template.
      - `:library_template_button_inputs` (list, optional): Array of objects for website and/or phone number used in the template.

  ## Notes

    - Previously, `allow_category_change` was supported to allow WhatsApp to update a template's category
      if they determined a different category was more appropriate. This behavior is now the default
      and the property is no longer needed.

  ## Example

      iex> template_data = %{
      ...>   name: "order_confirmation",
      ...>   category: "UTILITY",
      ...>   language: "en_US",
      ...>   parameter_format: "NAMED",
      ...>   components: components
      ...> }
      iex> WhatsappElixir.Templates.create_template(template_data)
      {:ok, %{"id" => "123456", "status" => "PENDING", "category" => "UTILITY"}}

  ## Validation

    - Raises `ArgumentError` if required fields (`name`, `category`, `language`, `components`) are missing.
  """
  def create_template(template_data, custom_config \\ []) do
    Enum.each([:name, :category, :language, :components], fn field ->
      if Map.get(template_data, field) in [nil, ""] do
        raise ArgumentError, "#{Atom.to_string(field)} must be provided"
      end
    end)

    body =
      Map.take(template_data, [
        :name,
        :category,
        :language,
        :components,
        :parameter_format,
        :library_template_name,
        :library_template_button_inputs
      ])

    HTTP.post(@endpoint, body, custom_config)
  end

  @doc """
  Lists message templates.

  ## Parameters

    - `fields`: Comma-separated list of fields to include in the response (optional).
    - `limit`: Maximum number of templates to return (optional).

  ## Example

      iex> WhatsappElixir.Templates.list_templates("name,status", 10)
      {:ok, %{"data" => [%{"name" => "template1", "status" => "APPROVED"}]}}
  """
  def list_templates(fields \\ "", limit \\ nil, custom_configs \\ []) do
    params =
      %{
        "fields" => fields,
        "limit" => limit
      }
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)

    HTTP.get(@endpoint, params, custom_configs)
  end

  @doc """
  Retrieve template namespace

  ## Example

  iex(7)> WhatsappElixir.Templates.retrieve_template_namespace(custom_configs)
    {:ok,
    %{
      "id" => "375688788962938",
      "message_template_namespace" => "87c5159f_1423_4819_8fe3_11e731b2d492"
    }}


  """
  def retrieve_template_namespace(custom_configs \\ []) do
    params = %{
      "fields" => "message_template_namespace"
    }

    HTTP.get("", params, custom_configs)
  end

  @doc """
  Edits an existing message template.

  ## Parameters

    - `template_id`: The ID of the template to edit.
    - `params`: A map containing the properties to be edited:
      - `category`: New category for the template (optional).
      - `components`: New components for the template (optional).

  ## Example

      iex> params = %{"category" => "MARKETING", "components" => new_components}
      iex> WhatsappElixir.Templates.edit_template("123456", params, custom_configs)
      {:ok, %{"success" => true}}

  """
  def edit_template(template_id, params, custom_configs \\ []) do
    HTTP.post("#{template_id}", params, custom_configs, false)
  end

  @doc """
  Deletes a message template by ID, name, or both.

  ## Parameters

    - `template_id`: The ID of the template to delete (optional).
    - `name`: The name of the template to delete (optional).

  ## Example

      iex> WhatsappElixir.Templates.delete_template("123456", "order_confirmation")
      {:ok, %{"success" => true}}

      iex> WhatsappElixir.Templates.delete_template(nil, "order_confirmation")
      {:ok, %{"success" => true}}

      iex> WhatsappElixir.Templates.delete_template("123456", nil)
      {:ok, %{"success" => true}}
  """
  def delete_template(template_id \\ nil, name \\ nil, custom_configs \\ []) do
    params =
      Enum.reduce([{"hsm_id", template_id}, {"name", name}], %{}, fn
        {_, nil}, acc -> acc
        {key, value}, acc -> Map.put(acc, key, value)
      end)

    HTTP.delete(@endpoint, params, custom_configs)
  end
end
