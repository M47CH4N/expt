defmodule Expt.Renderer do
  alias Expt.{Renderer, Camera, Scene, Ray, Vec, Material, Intersection, Const}

  def render_seq(%Scene{} = scene) do
    %Scene{
      samples: samples,
      supersamples: supersamples,
      camera: %Camera{
        width: width,
        height: height,
        position: pos,
        screen_x: scr_x,
        screen_y: scr_y,
        screen_center: scr_c
      }
    } = scene

    for y <- (height-1)..0 do
      for x <- 0..(width-1) do
        for sy <- 0..(supersamples-1),
            sx <- 0..(supersamples-1),
            _  <- 0..(samples-1) do
          rate = 1.0 / supersamples
          r1 = sx * rate + rate / 2.0
          r2 = sy * rate + rate / 2.0

          scr_p = scr_c
          |> Vec.add(scr_x |> Vec.mul((r1 + x) / width - 0.5))
          |> Vec.add(scr_y |> Vec.mul((r2 + y) / height - 0.5))

          ray = Ray.create(pos, scr_p |> Vec.sub(pos) |> Vec.normalize)
          Renderer.radiance(scene, ray, 0)
          |> Vec.div(samples)
          |> Vec.div(supersamples*supersamples)
        end
        |> Enum.reduce(Const.black, fn(radiance, acc) -> acc |> Vec.add(radiance) end)
      end
    end
  end
  def render(%Scene{} = scene) do
    %Scene{
      samples: samples,
      supersamples: supersamples,
      camera: %Camera{
        width: width,
        height: height,
        position: pos,
        screen_x: scr_x,
        screen_y: scr_y,
        screen_center: scr_c
      }
    } = scene

    scene_renderer = self()

    for y <- 0..(height-1) do
      spawn fn ->
        rendered_line = render_line(scene, width, height, supersamples, samples, y, scr_c, scr_x, scr_y, pos)
        send scene_renderer, {(height - y - 1), rendered_line}
      end
    end

    for y <- 0..(height-1) do
      receive do
        {^y, line} -> line
      end
    end
    |> List.flatten
  end
  def render_line(scene, w, h, ss, s, y, scr_c, scr_x, scr_y, pos) do
    for x <- 0..(w-1) do
      for sy <- 0..(ss-1),
          sx <- 0..(ss-1),
          _ <- 0..(s-1) do
        rate = 1.0 / ss
        r1 = sx * rate + rate / 2.0
        r2 = sy * rate + rate / 2.0

        scr_p = scr_c
        |> Vec.add(scr_x |> Vec.mul((r1 + x) / w - 0.5))
        |> Vec.add(scr_y |> Vec.mul((r2 + y) / h - 0.5))

        ray = Ray.create(pos, scr_p |> Vec.sub(pos) |> Vec.normalize)
        Renderer.radiance(scene, ray, 0)
        |> Vec.div(s)
        |> Vec.div(ss*ss)
      end
      |> Enum.reduce(Const.black, fn(radiance, acc) -> acc |> Vec.add(radiance) end)
    end
  end
  def radiance(scene, %Ray{dir: d} = ray, depth) do
    case Scene.intersect(scene, ray) do
      {:ok,
        %Intersection{
          normal: n,
          position: p,
          material: %Material{
            type: material_type,
            color: c,
            emission: e,
            ior: ior
          }
        }
      } ->
        case Renderer.russian_roulette(c, depth) do
          {:ok, rrp} ->
            case material_type do
              "Diffuse" ->
                diffuse(scene, d, n, p, c, rrp, depth)
              "Specular" ->
                specular(scene, d, n, p, c, rrp, depth)
              "Refraction" ->
                refraction(scene, d, n, p, c, ior, rrp, depth)
            end
            |> Vec.add(e)
          {:ng, _} -> e
        end
      {:ng, _} -> Const.black
    end
  end
  def russian_roulette(c, depth) do
    rrp = (c |> Tuple.to_list |> Enum.max) *
    if depth > Const.max_depth do
      :math.pow(0.5, depth - Const.max_depth)
    else
      1.0
    end

    if depth > Const.min_depth do
      if :rand.uniform >= rrp do
        {:ng, nil}
      else
        {:ok, rrp}
      end
    else
      {:ok, 1.0}
    end
  end
  def diffuse(scene, d, n, p, c, rrp, depth) do
    w = n |> Vec.mul(if (Vec.dot(n, d) < 0.0), do: 1.0, else: -1.0)
    u =
    (if abs(elem(w,0)) > Const.eps,
    do: {0.0, 1.0, 0.0},
    else: {1.0, 0.0, 0.0})
    |> Vec.cross(w)
    |> Vec.normalize
    v = w |> Vec.cross(u)

    # Importance Sampling
    r1 = 2 * :math.pi * :rand.uniform
    r2 = :rand.uniform
    r2s = :math.sqrt(r2)
    new_ray = Ray.create(
      p,
      u            |> Vec.mul(:math.cos(r1) * r2s)
      |> Vec.add(v |> Vec.mul(:math.sin(r1) * r2s))
      |> Vec.add(w |> Vec.mul(:math.sqrt(1.0 - r2)))
      |> Vec.normalize
    )

    Renderer.radiance(scene, new_ray, depth+1)
    |> Vec.mul(c |> Vec.div(rrp))
  end
  def specular(scene, d, n, p, c, rrp, depth) do
    Renderer.radiance(
      scene,
      Ray.create(
        p,
        d |> Vec.sub(n |> Vec.mul(2.0 * Vec.dot(n, d)))
      ),
      depth+1
    )
    |> Vec.mul(c |> Vec.div(rrp))
  end
  def refraction(scene, d, n, p, c, ior, rrp, depth) do
    reflec = Ray.create(p, Vec.sub(d, Vec.mul(n, 2.0 * Vec.dot(n, d))))
    o_n = Vec.mul(n, (if Vec.dot(n, d) < 0.0, do: 1.0, else: -1.0))
    into = Vec.dot(n, o_n) > 0.0

    # Snell's low
    nc = 1.0
    nt = ior
    nnt = if into, do: nc / nt, else: nt / nc
    ddn = Vec.dot(d, o_n)
    cos2t = 1.0 - nnt*nnt * (1.0 - ddn*ddn)

    if cos2t < 0.0 do
      Renderer.radiance(scene, reflec, depth+1)
      |> Vec.mul(c |> Vec.div(rrp))
    else
      refrac =
      Ray.create(p,
        Vec.mul(d, nnt)
        |> Vec.sub(Vec.mul(n, (if into, do: 1.0, else: -1.0) * (ddn * nnt + :math.sqrt(cos2t))))
        |> Vec.normalize
      )

      # Schlick's Fresnell estimation
      al = nt - nc
      be = nt + nc
      r0 = (al*al) / (be*be)

      th = 1.0 - (if into, do: -ddn, else: Vec.dot(refrac.dir, Vec.mul(o_n, -1.0)))
      re = r0 + (1.0 - r0) * :math.pow(th, 5.0)
      nnt2 = :math.pow((if into, do: nc / nt, else: nt / nc), 2.0)
      tr = (1.0 - re) * nnt2

      prb = 0.25 + 0.5 * re
      if depth > 2 do
        if :rand.uniform < prb do
          Renderer.radiance(scene, reflec, depth+1) |> Vec.mul(re)
          |> Vec.mul(c |> Vec.div(prb * rrp))
        else
          Renderer.radiance(scene, refrac, depth+1) |> Vec.mul(tr)
          |> Vec.mul(c |> Vec.div((1.0-prb) * rrp))
        end
      else
                   Renderer.radiance(scene, reflec, depth+1) |> Vec.mul(re)
        |> Vec.add(Renderer.radiance(scene, refrac, depth+1) |> Vec.mul(tr))
        |> Vec.mul(c |> Vec.div(rrp))
      end
    end
  end
end
