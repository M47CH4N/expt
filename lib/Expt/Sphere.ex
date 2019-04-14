defmodule Expt.Sphere do
  alias Expt.{Material, Ray, Sphere, Intersection, Const}
  use Expt.Vector

  defstruct pos: nil, radius: nil, material: %Material{}

  def get_pdf(%Sphere{radius: r}), do: 1.0/(4.0*:math.pi*r*r)

  def sample_surface(%Sphere{pos: pos, radius: r}) do
    r1 = 2 * :math.pi * :rand.uniform
    r2 = 1.0 - 2.0 * :rand.uniform
    r3 = :math.sqrt(1.0 - r2 * r2)
    pos + normalize({r3 * :math.cos(r1), r3 * :math.sin(r1), r2}) * r
  end

  def intersect(%Sphere{pos: p, radius: r}, %Ray{org: o, dir: d}) do
    p_o = p - o
    b2  = dot(p_o, d)
    c   = dot(p_o, p_o) - r*r
    d4  = b2*b2 - c
    if d4 < 0 do
      {:ng, nil}
    else
      rtd4 = :math.sqrt(d4)
      {t1, t2} = {b2 - rtd4, b2 + rtd4}
      if t1 < Const.eps && t2 < Const.eps do
        {:ng, nil}
      else
        t = if t1 > Const.eps, do: t1, else: t2
        pos = o + d * t
        {:ok, %Intersection{
          position: pos,
          distance: t,
          normal: (pos - p) |> normalize,
        }}
      end
    end
  end

end
