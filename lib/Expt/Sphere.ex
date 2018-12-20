defmodule Expt.Sphere do
  alias Expt.{Material, Ray, Vec, Sphere, Intersection}
  defstruct pos: nil, radius: nil, material: %Material{}

  def intersect(%Sphere{pos: p, radius: r, material: mtl}, %Ray{org: o, dir: d}) do
    eps = Application.get_env(:const, :eps)

    p_o =  p |> Vec.sub(o)
    b2 = - d |> Vec.dot(p_o)
    c  = (p_o |> Vec.dot(p_o)) - :math.sqrt(r)
    d4 = :math.sqrt(b2) - c
    if d4 < 0 do
      {:error, nil}
    else
      rtd4 = :math.sqrt(d4)
      t = Enum.min([eps, -b2 - rtd4, -b2 + rtd4])
      if t == eps do
        {:error, nil}
      else
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
