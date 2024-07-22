defmodule WhatsappElixirTest do
  use ExUnit.Case
  doctest WhatsappElixir

  test "greets the world" do
    assert WhatsappElixir.hello() == :world
  end
end
