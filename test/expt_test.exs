defmodule ExptTest do
  use ExUnit.Case
  doctest Expt

  test "greets the world" do
    assert Expt.hello() == :world
  end
end
