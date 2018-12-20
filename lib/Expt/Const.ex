defmodule Constant do
  defmacro const(name, value) do
    quote do
      def unquote(name), do: unquote(value)
    end
  end
end

defmodule Expt.Const do
  require Constant
  import Constant

  const black, {0.0, 0.0, 0.0}
  const eps, 1.0e-6
  const inf, 1.0e128
  const min_depth, 5
  const max_depth, 64
end
