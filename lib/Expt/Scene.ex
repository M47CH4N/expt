defmodule Expt.Scene do
  alias Expt.{Scene, Sphere, Intersection, Const}
  defstruct samples: nil, supersamples: nil, bvh_tree: [],
            camera: nil, objects: [], light_id: []

  def create(options) do
    %{
      samples: s,
      supersamples: ss,
      camera: cmr,
      objects: obj
    } = options |> Enum.into(%{})

    l_id = Enum.with_index(obj)
    |> Enum.filter(fn {o,_} -> o.material.emission != Const.black end)
    |> Enum.map(fn {_, k} -> k end)

    %Scene{
      samples: s,
      supersamples: ss,
      camera: cmr,
      objects: obj,
      light_id: l_id
    }
  end

  def sample_light_surface(%Scene{objects: objects, light_id: light_id}) do
    id = Enum.take_random(light_id, 1) |> List.first
    case Enum.fetch(objects, id) do
      {:ok, %Sphere{} = light} ->
        {Sphere.sample_surface(light), Sphere.get_pdf(light), id}
    end
  end

  def intersect(%Scene{objects: objects}, ray) do
    init = %Intersection{}
    case Scene.intersect(objects, ray, init, 0) do
      {:ok, intersection}
        -> {:ok, intersection}
      {:ng, _}
        -> {:ng, nil}
    end
  end

  def intersect([], _, nearest, _) do
    if nearest.distance == Const.inf do
      {:ng, nil}
    else
      {:ok, nearest}
    end
  end

  def intersect([head|tail], ray, nearest, id) do
    result = case head do
      %Sphere{}
        -> Sphere.intersect(head, ray)
    end
    nearest = case result do
      {:ok, intersection} ->
        if intersection.distance < nearest.distance do
          %Intersection{
            distance: intersection.distance,
            normal: intersection.normal,
            position: intersection.position,
            id: id
          }
        else
          nearest
        end
      {:ng, _} -> nearest
    end
    Scene.intersect(tail, ray, nearest, id+1)
  end

end
