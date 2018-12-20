defmodule Expt.Sphere do
  alias Expt.{Material, Ray, Vec, Sphere, Intersection, Const}
  defstruct pos: nil, radius: nil, material: %Material{}

  def intersect(%Sphere{pos: p, radius: r, material: mtl}, %Ray{org: o, dir: d}) do
    p_o =  p |> Vec.sub(o)
    b2 = p_o |> Vec.dot(d)
    c  = (p_o |> Vec.dot(p_o)) - r*r
    d4 = b2*b2 - c
    if d4 < 0 do
      {:ng, nil}
    else
      rtd4 = :math.sqrt(d4)
      {t1, t2} = {b2 - rtd4, b2 + rtd4}
      if t1 < Const.eps && t2 < Const.eps do
        {:ng, nil}
      else
        t = if t1 > Const.eps, do: t1, else: t2
        pos = o |> Vec.add(Vec.mul(d, t))
        {:ok, %Intersection{
          position: pos,
          distance: t,
          normal: (pos |> Vec.sub(p)) |> Vec.normalize,
          material: mtl
        }}
      end
    end
  end
end
