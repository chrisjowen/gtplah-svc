defmodule GtpLah.Chat.FunctionHandler do
  def handle(%{"name" => "list_events"} = opts) do
    IO.inspect("called function list_events: #{inspect(opts)} ")

    {:ok,
     [
       %{
         type: "event",
         start: "2021-08-01T00:00:00+08:00",
         end: "2021-08-01T00:00:00+08:00",
         address: "Singapore",
         title: "Singapore National Day",
         description: "Come and celebrate Singapore's 56th birthday!",
         url: "https://www.ndp.gov.sg/ndp-at-padang/"
       },
        %{
          type: "event",
          start: "2021-08-01T00:00:00+08:00",
          end: "2021-08-01T00:00:00+08:00",
          address: "Van Gogh Expo",
          title: "Van Gogh Expo",
          description: "Tap into the artist’s world of wonder, now at Resorts World Sentosa! Be inspired in a 360° multi-sensorial exhibition where art meets VR, surround yourself with over 300 artworks by renowned artist Vincent Van Gogh and even try your hand at creating your own masterpiece!",
          url: "https://vangoghexpo.com/singapore/"
        },
     ]}
  end

  def definitions() do
    [
      %{
        "name" => "list_events",
        "description" => "Get events in singapore, can filter by categories or date",
        "parameters" => %{
          "type" => "object",
          "properties" => %{
            "categories" => %{
              "type" => "string"
            },
            "when" => %{
              "type" => "string"
            }
          }
        }
      }
    ]
  end
end
