scene = %Expt.Scene{
  samples: 256,
  supersamples: 1,
  camera: Expt.Camera.create([
    position: {50.0, 52.0, 220.0},
    direction: {0.0, -0.04, -1.0},
    width: 128,
    height: 128
  ]),
  objects: [
    %Expt.Sphere{
      radius: 1.0e5,
      pos: {1.0e5+1, 40.8, 81.6},
      material: %Expt.Material{
        type: "Diffuse",
        color: {0.75, 0.25, 0.25}
      }
    },
    %Expt.Sphere{
      radius: 1.0e5,
      pos: {-1.0e5+99, 40.8, 81.6},
      material: %Expt.Material{
        type: "Diffuse",
        color: {0.25, 0.25, 0.75}
      }
    },
    %Expt.Sphere{
      radius: 1.0e5,
      pos: {50, 40.8, 1.0e5},
      material: %Expt.Material{
        type: "Diffuse",
        color: {0.75, 0.75, 0.75}
      }
    },
    %Expt.Sphere{
      radius: 1.0e5,
      pos: {50, 40.8, -1.0e5+250},
      material: %Expt.Material{
        type: "Diffuse"
      }
    },
    %Expt.Sphere{
      radius: 1.0e5,
      pos: {50, 1.0e5, 81.6},
      material: %Expt.Material{
        type: "Diffuse",
        color: {0.75, 0.75, 0.75}
      }
    },
    %Expt.Sphere{
      radius: 1.0e5,
      pos: {50, -1.0e5+81.6, 81.6},
      material: %Expt.Material{
        type: "Diffuse",
        color: {0.75, 0.75, 0.75}
      }
    },
    %Expt.Sphere{
      radius: 20,
      pos: {65, 20, 20},
      material: %Expt.Material{
        type: "Diffuse",
        color: {0.25, 0.75, 0.25}
      }
    },
    %Expt.Sphere{
      radius: 16.5,
      pos: {27, 16.5, 47},
      material: %Expt.Material{
        type: "Specular",
        color: {0.99, 0.99, 0.99}
      }
    },
    %Expt.Sphere{
      radius: 16.5,
      pos: {77, 16.5, 78},
      material: %Expt.Material{
        type: "Refraction",
        ior: Expt.Material.Ior.quartz,
        color: {0.99, 0.99, 0.99}
      }
    },
    %Expt.Sphere{
      radius: 15.0,
      pos: {50.0, 90.0, 81.6},
      material: %Expt.Material{
        type: "Diffuse",
        emission: {36, 36, 36}
      }
    },
  ]
}

IO.puts "Rendering..."

{time_ns, _} =
:timer.tc(fn ->
  scene
  |> Expt.Renderer.render()
  |> Expt.Image.to_png(scene.camera.width, scene.camera.height)
  |> ExPNG.write("cornellbox.png")
end)

time_s = Float.round(time_ns / 1_000_000, 3)
IO.puts "Completed in #{time_s}s"
