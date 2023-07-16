defmodule Util.StringUtil do
  def extract_urls(string) do
    regex =
      ~r/(https?:\/\/)*(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&\/\/=]*)/

    Regex.scan(regex, string)
    |> Enum.map(fn [h | _] ->
      case h do
        "http://" <> _ -> h
        "https://" <> _ -> h
        _ -> "http://#{h}"
      end
    end)
  end

  def extract_tags(string) do
    regex = ~r/#([a-zA-Z0-9\-]+)/
    Regex.scan(regex, string)
    |> Enum.flat_map(fn [_ | tag] -> tag end)
  end

end
