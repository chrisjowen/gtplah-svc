defmodule Util.AtomUtil do
  def string_to_atom(str) do
    try do
      String.to_existing_atom(str)
    rescue
      ArgumentError -> String.to_atom(str)
    end
  end
end
