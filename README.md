# Expt
A simple Pathtracer written in Elixir.

![cornellbox](https://github.com/M47CH4N/expt/blob/images/cornellbox.png)

## Features
- Shapes
  - Sphere
- Reflection Models
  - Lambertian (with Cosine weighted importance sampling)
  - Specular
  - Refraction
- Other Accelerations
  - Next Event Estimation(Direct illumination)
  - Parallel rendering

## Usage
```bash
$ git clone github.com:M47CH4N/expt.git && cd ./expt
$ mix deps.get
$ mix run ./scene/cornellbox.exs
```

## Benchmarks
On Ryzen 7 2700X @3.7GHz

|scene|1x1spp|
|:--|--:|
|cornellbox|8.532s|

## LICENSE
Expt is released under the MIT License([LICENSE file](https://github.com/M47CH4N/expt/blob/master/LICENSE)).

A part of this software is based on [githole/edupt](http://kagamin.net/hole/edupt/index.htm) and [xavier/exray](https://github.com/xavier/exray).