defmodule WhatsappElixir.Message do
  alias WhatsappElixir.Static

  defstruct [
    :id,
    :data,
    :content,
    :to,
    :rec_type,
    :type,
    :sender,
    :name,
    :image,
    :video,
    :audio,
    :document,
    :location,
    :interactive
  ]

  def new(data) do
    %WhatsappElixir.Message{
      id: Static.get_message_id(data),
      data: data,
      content: Static.get_message(data) || "",
      to: "",
      rec_type: "individual",
      type: Static.get_message_type(data) || "text",
      sender: Static.get_mobile(data),
      name: Static.get_name(data),
      image: Static.get_image(data),
      video: Static.get_video(data),
      audio: Static.get_audio(data),
      document: Static.get_document(data),
      location: Static.get_location(data),
      interactive: Static.get_interactive_response(data)
    }
  end
end
