defmodule SumiTest do
  use ExUnit.Case
  doctest Sumi

  test "greets the world" do
    assert Sumi.hello() == :world
  end
end
