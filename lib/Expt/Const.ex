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
  const white, {1.0, 1.0, 1.0}
  const eps, 1.0e-6
  const inf, 1.0e128
  const inf3, {1.0e128, 1.0e128, 1.0e128}
  const max_depth, 5

end
