# WhatsappElixir

**WhatsappElixir** is an Elixir library for interacting with the WhatsApp API. It allows you to handle incoming messages and send responses efficiently using a clean and simple API.

## Installation

To use **WhatsappElixir** in your project, add it to your `mix.exs` dependencies:


```elixir
def deps do
  [
    {:whatsapp_elixir, "0.1.6"}
  ]
end
```

 ## Configuration

  Configure your WhatsApp credentials in `config/config.exs`:

      config :whatsapp_elixir,WhatsappElixir.HTTP,
        token: System.get_env("WHATSAPP_TOKEN"),
        phone_number_id: System.get_env("WHATSAPP_PHONE_NUMBER_ID"),
        verify_token: System.get_env("VERIFY_TOKEN")

  """

  Config can be left blank if you wish to pass the config at the app.

  ## Usage
  sending whatsapp message example this only works with users with existing sessions to send message first time use templated message on user reply session will be created. 

  ### messages & templated message

  ```elixir
  defmodule MyModule do
  alias WhatsappElixir.Messages

  def send_message(mobile_number) do
   Messages.send_message(mobile_number, "Hello World")
  end

  def send_templated(mobile_number) do
  Messages.send_template("hello_world", mobile_number, [] )
  end

 end
 ```

## Sends an image message to a WhatsApp user.

Args
  - image: Image id or link of the image
  - recipient_id: Phone number of the user with country code without +
  - recipient_type: Type of the recipient, either individual or group (default is "individual")
  - caption: Caption of the image (default is "")
  - link: Whether to send an image id or an image link, True means that the image is a link, False means that the image is an id (default is true)



```elixir
 iex> WhatsappElixir.send_image("https://i.imgur.com/Fh7XVYY.jpeg", "5511999999999")
 
```


## Send Template Message
```elixir
defmodule MyModule do
  alias WhatsappElixir.Messages

  def send_templated(mobile_number) do
    Messages.send_template("hello_world", mobile_number, [])
  end
end
```


