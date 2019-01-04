defmodule Expt.Camera do
  alias Expt.{Vec, Camera}
  defstruct width: nil, height: nil, position: nil, screen_x: nil, screen_y: nil, screen_center: nil

  def create(options \\ []) do
    defaults = [up: {0.0, 1.0, 0.0}, screen_height: 30.0, screen_distance: 40.0]
    %{
      width: width,
      height: height,
      position: pos,
      direction: dir,
      up: up,
      screen_height: scr_h,
      screen_distance: scr_d
    } = Keyword.merge(defaults, options) |> Enum.into(%{})

    dir = dir |> Vec.normalize
    up  = up  |> Vec.normalize
    scr_w = scr_h * width / height
    scr_x = dir   |> Vec.cross(up)  |> Vec.normalize |> Vec.mul(scr_w)
    scr_y = scr_x |> Vec.cross(dir) |> Vec.normalize |> Vec.mul(scr_h)
    scr_c = pos   |> Vec.add(Vec.mul(dir, scr_d))

    %Camera{
      width: width,
      height: height,
      position: pos,
      screen_x: scr_x,
      screen_y: scr_y,
      screen_center: scr_c
    }
  end

end
