defmodule Expt.Operator do
  import Kernel, except: [+: 2, -: 1, -: 2, *: 2, /: 2]
  alias Expt.Operator

  def create(x, y, z) do
    {x, y, z}
  end

  def a + b
    when is_number(a) and is_number(b) do
    Kernel.+(a, b)
  end

  def ({x1, y1, z1} = v1) + ({x2, y2, z2} = v2)
    when is_tuple(v1) and is_tuple(v2) do
    {Kernel.+(x1, x2), Kernel.+(y1, y2), Kernel.+(z1, z2)}
  end

  def -a when is_number(a) do
    Kernel.-(a)
  end

  def -v when is_tuple(v) do
    {x, y, z} = v
    {-x, -y, -z}
  end

  def a - b
    when is_number(a) and is_number(b) do
    Kernel.-(a, b)
  end

  def ({x1, y1, z1} = v1) - ({x2, y2, z2} = v2)
    when is_tuple(v1) and is_tuple(v2) do
    {Kernel.-(x1, x2), Kernel.-(y1, y2), Kernel.-(z1, z2)}
  end

  def a * b
    when is_number(a) and is_number(b) do
    Kernel.*(a, b)
  end

  def ({x1, y1, z1} = v1) * ({x2, y2, z2} = v2)
    when is_tuple(v1) and is_tuple(v2) do
    {Kernel.*(x1, x2), Kernel.*(y1, y2), Kernel.*(z1, z2)}
  end

  def ({x, y, z} = v) * s
    when is_tuple(v) and is_number(s) do
    {Kernel.*(x, s), Kernel.*(y, s), Kernel.*(z, s)}
  end

  def s * ({x, y, z} = v)
    when is_tuple(v) and is_number(s) do
    {Kernel.*(x, s), Kernel.*(y, s), Kernel.*(z, s)}
  end

  def a / b
    when is_number(a) and is_number(b) do
    Kernel./(a, b)
  end

  def ({x1, y1, z1} = v1) / ({x2, y2, z2} = v2)
    when is_tuple(v1) and is_tuple(v2) do
    {Kernel./(x1, x2), Kernel./(y1, y2), Kernel./(z1, z2)}
  end

  def ({x, y, z} = v) / d
    when is_tuple(v) and is_number(d) do
    {Kernel./(x, d), Kernel./(y, d), Kernel./(z, d)}
  end

  def dot(v1, v2) do
    {x, y, z} = v1 * v2
    Kernel.+(x, Kernel.+(y, z))
  end

  def cross({x1, y1, z1}, {x2, y2, z2}) do
    {
      Kernel.-(Kernel.*(y1, z2), Kernel.*(z1, y2)),
      Kernel.-(Kernel.*(z1, x2), Kernel.*(x1, z2)),
      Kernel.-(Kernel.*(x1, y2), Kernel.*(y1, x2)),
    }
  end

  def length(vec) do
    vec
    |> Operator.dot(vec)
    |> :math.sqrt
  end

  def normalize(vec) do
    vec / Operator.length(vec)
  end

  def min({x1, y1, z1} = v1, {x2, y2, z2} = v2)
    when is_tuple(v1) and is_tuple(v2) do
    {Kernel.min(x1,x2), Kernel.min(y1,y2), Kernel.min(z1,z2)}
  end

  def max({x1, y1, z1} = v1, {x2, y2, z2} = v2)
    when is_tuple(v1) and is_tuple(v2) do
    {Kernel.max(x1,x2), Kernel.max(y1,y2), Kernel.max(z1,z2)}
  end

end
