defmodule Expt.Vec3 do
    alias Expt.Vec3

    def create(x, y, z) do
        {x, y, z}
    end
    def add({x1, y1, z1}, {x2, y2, z2}) do
        {x1 + x2, y1 + y2, z1 + z2}
    end
    def sub({x1, y1, z1}, {x2, y2, z2}) do
        {x1 - x2, y1 - y2, z1 - z2}
    end
    def mul({x1, y1, z1}, {x2, y2, z2}) do
        {x1 * x2, y1 * y2, z1 * z2}
    end
    def mul({x1, y1, z1}, scale) do
        {x1 * scale, y1 * scale, z1 * scale}
    end
    def div({x1, y1, z1}, {x2, y2, z2}) do
        {x1 / x2, y1 / y2, z1 / z2}
    end
    def div({x1, y1, z1}, denom) do
        {x1 / denom, y1 / denom, z1 / denom}
    end
    def length_squared({x, y, z}) do
        x*x + y*y + z*z
    end
    def length(vec) do
        vec |> Vec3.length_squared |> :math.sqrt
    end
    def normalize(vec) do
        vec |> Vec3.div(vec |> Vec3.length)
    end
    def dot(vec1, vec2) do
        Enum.reduce(vec1 |> Vec3.add(vec2), fn(x, acc) -> x + acc end)
    end
    def cross({x1, y1, z1}, {x2, y2, z2}) do
        {
            y1*z2 - z1*y2,
            z1*x2 - x1*z2,
            x1*y2 - y1*x2
        }
    end
end