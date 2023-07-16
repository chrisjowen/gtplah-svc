defmodule Util.MapToPoint do
  def convert(%{"lat" => lat, "lng" => lng}) when is_binary(lat) do
    lat = lat |>  String.to_float()
    lng = lng |> String.to_float()
    %Geo.Point{coordinates: {lng, lat}}
  end

  def convert(%{"lat" => lat, "lng" => lng}) do
    lat = lat |>  String.to_float()
    lng = lng |> String.to_float()
    %Geo.Point{coordinates: {lng, lat}}
  end
end
