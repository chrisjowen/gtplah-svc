defmodule GtpLah.Workers.LinkProcessingWorker do
  require Logger
  alias GtpLah.Schema.MessageLink
  alias GtpLah.Schema.Link
  alias GtpLah.Eventing.Repo
  alias GtpLah.Workers.MessageTaggingWorker

  use Oban.Worker,
    queue: :links,
    max_attempts: 1

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "url" => url,
          "created_by_id" => created_by_id,
          "tags" => message_tags,
          "message_id" => message_id
        }
      }) do
    with {:ok, response} <- HTTPoison.get(url, [], follow_redirect: true) do
      try do
        link_params = extract_meta(response, url, message_tags, created_by_id)
        tags = extract_tags(link_params)
        link_params = Map.put(link_params, :tags, tags)

          link = Link.changeset(link_params)
          |> Repo.insert!()


          MessageLink.changeset(%{
            message_id: message_id,
            link_id: link.id
          })
          |> Repo.insert!()


        MessageTaggingWorker.new(%{
          message_id: message_id
        })
        |> Oban.insert()

        :ok
      rescue
        e ->
          Logger.error(inspect(e))
          e
      end
    else
      {:error, %HTTPoison.Error{reason: reason} = error} ->
        Logger.error("Error fetching #{url}: #{inspect(reason)} #{inspect(error)}")
        :error

      {:error, %HTTPoison.Response{status_code: status_code}} ->
        Logger.error("Error fetching #{url}: #{inspect(status_code)}")
        :error

      error ->
        Logger.error("#{inspect(error)}")
        :error
    end
  end

  defp extract_tags(params) do

    with {:ok, result} <-
           Ai.ContentTagger.execute(%{"content" => "#{params.title} - #{params.description}"}) do
      Enum.uniq(result["tags"] ++ params.tags)
    else
      _ -> params.tags
    end
  end

  defp extract_meta(response, url, message_tags, created_by_id) do
    {:ok, document} = Floki.parse_document(response.body)

    title =
      document
      |> Floki.find("head title")
      |> Floki.text()
      |> String.trim()

    alt_title =
      document
      |> Floki.find("h1")
      |> Floki.text()
      |> String.trim()

    alt_description =
      document
      |> Floki.find("p")
      |> Floki.text()
      |> String.slice(0, 50)

    description =
      document
      |> Floki.find("meta[name=description]")
      |> Floki.attribute("content")
      |> List.first("")

    tags =
      document
      |> Floki.find("meta[name=keywords]")
      |> Floki.attribute("content")
      |> List.first("")
      |> String.split(",")
      |> Enum.filter(&(&1 != ""))

    %{
      url: url,
      title: if(title == "", do: alt_title, else: title),
      description:
        if(description == "" || description == nil,
          do: alt_description,
          else: description
        ),
      tags: tags ++ message_tags,
      created_by_id: created_by_id
    }
  end
end
