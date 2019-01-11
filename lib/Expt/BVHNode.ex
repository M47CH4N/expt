defmodule Expt.BVHNode do
  alias Expt.{Scene, BBox}
  defstruct bbox: %BBox{}, children: [], objects: []

  def constructBVH(%Scene{} = scene) do
  end

  def constructBVH(scene, set) do

  end
end
