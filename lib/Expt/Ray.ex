defmodule Expt.Ray do
    defstruct org: nil, dir: nil

    alias Expt.{Vec, Ray}

    def create(o, d) do
        %Ray{org: o, dir: d}
    end
    def march(%Ray{org: o, dir: d}, t) do
        o |> Vec.add(d |> Vec.mul(t))
    end
end
