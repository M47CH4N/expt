defmodule Expt.Image do

  @doc "Transforms the rendered output into a PNG image ready to be compressed"
  def to_png(render_output, width, height) do
    img = ExPNG.Image.new(width, height)
    %{img | pixels: to_pixels(render_output)}
  end

  @doc "Convers rendered output into pixels usable by the PNG writer"
  def to_pixels(render_output) do
    for {r, g, b} <- render_output, into: <<>> do
      pr = to_8bpp(r)
      pg = to_8bpp(g)
      pb = to_8bpp(b)
      ExPNG.Color.rgb(pr, pg, pb)
    end
  end

  defp clamp(x, a, b) do x |> max(a) |> min(b) end
  defp mul(a, b), do: a * b
  defp to_8bpp(x, scale \\ 255) do
    x
    |> clamp(0.0, 1.0)
    |> :math.pow(1/2.2)
    |> mul(scale)
    |> round
    |> clamp(0, scale)
  end
end
