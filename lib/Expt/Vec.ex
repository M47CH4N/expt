defmodule Expt.Vec do
  alias Expt.Vec

  def create(x, y, z) do
    {x, y, z}
  end

  def add({x1, y1, z1}, {x2, y2, z2}) do
    {x1 + x2, y1 + y2, z1 + z2}
  end

  def sub({x1, y1, z1}, {x2, y2, z2}) do
    {x1 - x2, y1 - y2, z1 - z2}
  end

  def mul({x1, y1, z1}, {x2, y2, z2}) do
    {x1 * x2, y1 * y2, z1 * z2}
  end

  def mul({x1, y1, z1}, scale) do
    {x1 * scale, y1 * scale, z1 * scale}
  end

  def div({x1, y1, z1}, {x2, y2, z2}) do
    {x1 / x2, y1 / y2, z1 / z2}
  end

  def div({x1, y1, z1}, denom) do
    {x1 / denom, y1 / denom, z1 / denom}
  end

  def dot({x1, y1, z1}, {x2, y2, z2}) do
    x1*x2 + y1*y2 + z1*z2
  end

  def cross({x1, y1, z1}, {x2, y2, z2}) do
    {
      y1*z2 - z1*y2,
      z1*x2 - x1*z2,
      x1*y2 - y1*x2
    }
  end

  def length(vec) do
    vec
    |> Vec.dot(vec)
    |> :math.sqrt
  end

  def normalize(vec) do
    vec
    |> Vec.div(Vec.length(vec))
  end

end
