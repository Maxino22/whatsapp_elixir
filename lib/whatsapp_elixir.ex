defmodule WhatsappElixir do
  @moduledoc """
   **WhatsappElixir** is an Elixir API wrapper for interacting with the WhatsApp API.

  ## Installation

  To use **WhatsappElixir** in your project, add it to your `mix.exs` dependencies:

      defp deps do
        [
          {:whatsapp_elixir, git: "git@bitbucket.org:bitfactor/whatsapp_elixir.git"}
        ]
      end

  Then, run `mix deps.get` to fetch and install the dependency.

  ## Configuration

  Configure your WhatsApp credentials in `config/config.exs`:

      config :whatsapp_elixir,
        token: System.get_env("WHATSAPP_TOKEN"),
        phone_number_id: System.get_env("WHATSAPP_PHONE_NUMBER_ID")
  """

  defstruct token: nil, phone_number_id: nil

  @doc """
  Creates a new `WhatsappElixir` struct with the given token and phone number ID.

  ## Parameters

  - `token`: The token to be used for authentication.
  - `phone_number_id`: The phone number ID associated with the WhatsApp account.

  ## Examples

      iex> WhatsappElixir.new("your_token", "your_phone_number_id")
      %WhatsappElixir{token: "your_token", phone_number_id: "your_phone_number_id"}

  """
  def new(token, phone_number_id) do
    %WhatsappElixir{
      token: token,
      phone_number_id: phone_number_id
    }
  end

  @doc """
  Verifies if the provided token matches the expected token.

  ## Parameters

  - `expected_token`: The token expected.
  - `provided_token`: The token to be verified.

  ## Examples

      iex> WhatsappElixir.verify_token("expected_token", "provided_token")
      true

      iex> WhatsappElixir.verify_token("expected_token", "wrong_token")
      false

  """
  def verify_token(expected_token, provided_token) do
    expected_token == provided_token
  end
end
