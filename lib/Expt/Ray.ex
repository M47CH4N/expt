defmodule Expt.Ray do
  alias Expt.Ray
  defstruct org: nil, dir: nil

  def create(o, d) do
    %Ray{org: o, dir: d}
  end

end
