defmodule Expt.BBox do
  alias Expt.{BBox, Const, Operator}
  import Kernel, except: [+: 2, -: 2, *: 2, /: 2]
  import Operator

  defstruct p_min: Const.inf3 * -1.0, p_max: Const.inf3

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

end
