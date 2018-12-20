defmodule Expt.Scene do
  alias Expt.{Scene, Sphere, Intersection, Const}

  defstruct width: nil, height: nil, samples: nil, supersamples: nil,
            camera: nil, objects: []

  def intersect(scene, ray) do
    init =
    %Intersection{
      distance: Const.inf,
      normal: nil,
      position: nil,
      material: nil
    }
    objects = scene.objects
    case Scene.intersect(objects, ray, init) do
      {:ok, intersection}
        -> {:ok, intersection}
      {:ng, _}
        -> {:ng, nil}
    end
  end
  def intersect([], _, nearest) do
    if nearest.distance == Const.inf do
      {:ng, nil}
    else
      {:ok, nearest}
    end
  end
  def intersect([head|tail], ray, nearest) do
    {hit, intersection} =
    case head do
      %Sphere{}
        -> Sphere.intersect(head, ray)
    end
    nearest =
    if hit == :ok && intersection.distance < nearest.distance,
    do: intersection,
    else: nearest

    Scene.intersect(tail, ray, nearest)
  end
end
