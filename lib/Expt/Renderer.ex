defmodule Expt.Renderer do
  alias Expt.{Renderer, Camera, Scene, Ray, Material, Intersection, Const}
  use Expt.Vector

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

    for y <- 0..(height-1) do
      render_line(scene, width, height, supersamples, samples, y, scr_c, scr_x, scr_y, pos)
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

        scr_p = scr_c +
                scr_x * ((r1 + x) / w - 0.5) +
                scr_y * ((r2 + y) / h - 0.5)

        ray = Ray.create(pos, normalize(scr_p - pos))
        Renderer.radiance(scene, ray, Const.white, true, 0) / s / (ss*ss)
      end
      |> Enum.reduce(Const.black, fn(radiance, acc) -> acc + radiance end)
    end
  end

  def radiance(scene, %Ray{} = ray, weight, is_direct, depth) do
    case Scene.intersect(scene, ray) do
      {:ng, _} -> Const.black
      {:ok, %Intersection{} = intersection} ->
        {:ok, %{material: %Material{} = mtl}} = Enum.fetch(scene.objects, intersection.id)
        o_n = orienting_normal(ray.dir, intersection.normal)

        direct_light(is_direct, mtl.emission, weight) +
        case russian_roulette(mtl.color, depth) do
          {:ng, _} -> Const.black
          {:ok, rr_prob} ->
            case mtl.type do
              "Diffuse" ->
                diffuse(scene, o_n, intersection, mtl, rr_prob, weight, depth) +
                next_event_estimation(scene, intersection, mtl.color, weight, o_n)
              "Specular" ->
                specular(scene, ray.dir, intersection, mtl, rr_prob, weight, depth)
              "Refraction" ->
                refraction(scene, o_n, ray.dir, intersection, mtl, rr_prob, weight, depth)
            end
        end
    end
  end

  def direct_light(is_direct, emission, weight) do
    if is_direct, do: weight * emission, else: Const.black
  end

  def orienting_normal(d, n) do
    if (dot(n, d) < 0.0), do: n, else: -1.0*n
  end

  def russian_roulette(color, depth) do
    rr_prob = (color |> Tuple.to_list |> Enum.max)

    if depth > Const.max_depth do
      if :rand.uniform >= rr_prob do
        {:ng, nil}
      else
        {:ok, rr_prob}
      end
    else
      {:ok, 1.0}
    end
  end

  def next_event_estimation(scene, intersection, color, weight, orienting_n) do
    if Enum.member?(scene.light_id, intersection.id) do
      Const.black
    else
      {light_pos, light_pdf, light_id} = Scene.sample_light_surface(scene)
      light_dir  = light_pos - intersection.position
      dist_sq    = dot(light_dir, light_dir)
      nlight_dir = normalize(light_dir)
      shadow_ray = Ray.create(intersection.position, nlight_dir)

      case Scene.intersect(scene, shadow_ray) do
        {:ok, %Intersection{
          normal: light_n,
          id: ^light_id
        }} ->
          {:ok, light} = Enum.fetch(scene.objects, light_id)
          dot1 = dot(orienting_n, nlight_dir) |> abs
          dot2 = dot(light_n, nlight_dir * -1.0) |> abs
          g    = dot1 * dot2 / dist_sq

          weight * light.material.emission * (color / :math.pi) * g / light_pdf

        _ -> Const.black
      end
    end
  end

  def diffuse(scene, o_n, intersection, mtl, rr_prob, weight, depth) do
    new_ray = cos_weighted_sample(intersection, get_onb(o_n))
    new_weight = weight * mtl.color / rr_prob
    Renderer.radiance(scene, new_ray, new_weight, false, depth+1)
  end

  def specular(scene, dir, intersection, mtl, rr_prob, weight, depth) do
    reflec = get_reflect(intersection, dir)
    new_weight = weight * mtl.color / rr_prob
    Renderer.radiance(scene, reflec, new_weight, true, depth+1)
  end

  def refraction(scene, o_n, dir, intersection, mtl, rr_prob, weight, depth) do
    reflec = get_reflect(intersection, dir)
    into = dot(intersection.normal, o_n) > 0.0

    # Snell's low
    nc = 1.0
    nt = mtl.ior
    nnt = if into, do: nc / nt, else: nt / nc
    ddn = dot(dir, o_n)
    cos2t = 1.0 - nnt*nnt * (1.0 - ddn*ddn)

    if cos2t < 0.0 do
      new_weight = weight * mtl.color / rr_prob
      Renderer.radiance(scene, reflec, new_weight, true, depth+1)
    else
      refrac = get_refract(intersection, dir, nnt, into, ddn, nnt, cos2t)

      # Schlick's Fresnell estimation
      al = nt - nc
      be = nt + nc
      r0 = (al*al) / (be*be)

      th = 1.0 - (if into, do: -ddn, else: dot(refrac.dir, o_n * -1.0))
      re = r0 + (1.0 - r0) * :math.pow(th, 5.0)
      nnt2 = :math.pow((if into, do: nc / nt, else: nt / nc), 2.0)
      tr = (1.0 - re) * nnt2

      prob = 0.25 + 0.5 * re
      if :rand.uniform < prob do
        new_weight = weight * mtl.color * re / prob / rr_prob
        Renderer.radiance(scene, reflec, new_weight, true, depth+1)
      else
        new_weight = weight * mtl.color * tr / (1.0-prob) / rr_prob
        Renderer.radiance(scene, refrac, new_weight, true, depth+1)
      end
    end
  end

  def get_onb(normal) do
    w = normal
    u =
    if abs(elem(w,0)) > Const.eps do
      {0.0, 1.0, 0.0}
    else
      {1.0, 0.0, 0.0}
    end
    |> cross(w)
    |> normalize
    v = w |> cross(u)
    %{w: w, u: u, v: v}
  end

  def cos_weighted_sample(intersection, onb) do
    r1 = 2 * :math.pi * :rand.uniform
    r2 = :rand.uniform
    r2s = :math.sqrt(r2)
    Ray.create(
      intersection.position,
      normalize(
        onb.u * :math.cos(r1) * r2s +
        onb.v * :math.sin(r1) * r2s +
        onb.w * :math.sqrt(1.0 - r2)))
  end

  def get_reflect(intersection, dir) do
    Ray.create(
      intersection.position,
      dir - intersection.normal * 2.0 * dot(intersection.normal, dir))
  end

  def get_refract(intersection, dir, nnt, into, ddn, nnt, cos2t) do
    Ray.create(
      intersection.position,
      normalize(
        dir * nnt -
        intersection.normal * (if into, do: 1.0, else: -1.0) *
        (ddn * nnt + :math.sqrt(cos2t))
      ))
  end

end
