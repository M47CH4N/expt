defmodule Expt.Ray do
    defstruct org: nil, dir: nil
    
    alias Expt.{Vec3, Ray}

    def create(o, d) do
        %Ray{org: o, dir: d}
    end
    def march(%Ray{org: o, dir: d}, t) do
        o |> Vec3.add(d |> Vec3.mul(t))
    end
end