defmodule Expt.BBox do
  alias Expt.{BBox, Ray, Const, Operator}
  import Kernel, except: [+: 2, -: 1, -: 2, *: 2, /: 2]
  import Operator

  defstruct p_min: -Const.inf3, p_max: Const.inf3

  def get_area(%BBox{} = bbox) do
    {dx, dy, dz} = bbox.p_max - bbox.p_min
    2 * (dx*dy + dx*dz + dy*dz)
  end

  def merge_bbox(%BBox{} = bbox1, %BBox{} = bbox2) do
    %BBox{
      p_min: Operator.min(bbox1.p_min, bbox2.p_min),
      p_max: Operator.max(bbox1.p_max, bbox2.p_max)
    }
  end

  def intersect(%BBox{p_min: p_min, p_max: p_max}, %Ray{org: o, dir: d}) do
    t1 = (p_min - o) / d
    t2 = (p_max - o) / d
    t_max = Enum.min(Operator.max(t1, t2) |> Tuple.to_list)
    t_min = Enum.max(Operator.min(t1, t2) |> Tuple.to_list)
    t_min <= t_max && t_max >= 0.0
  end

end
