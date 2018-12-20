defmodule Expt.Material do
  defstruct type: nil, color: {0.0, 0.0, 0.0}, emission: {0.0, 0.0, 0.0}, ior: nil

  defmodule Ior do
    require Constant
    import Constant

    const air, 1.000292
    const ice, 1.309
    const water, 1.3334
    const quartz, 1.5443
    const sapphire, 1.766
    const diamond, 2.417
  end
end
