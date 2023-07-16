defmodule GtpLah.Workers.MessageTaggingWorker do
  require Logger
  alias GtpLah.Eventing.Repo
  alias GtpLah.Schema.Message

  use Oban.Worker,
    queue: :messages,
    max_attempts: 1

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"message_id" => message_id}}) do
    Logger.info("Starting to tag message #{message_id}")
    message = Repo.get(Message, message_id) |> Repo.preload([:links])

    links_map =
      Enum.map(message.links, fn link ->
        {link.url, "#{link.title} - #{link.description}"}
      end)
      |> Enum.into(%{})

    with {:ok, result} <-
           Ai.ContentTagger.execute(%{
             "content" => "#{message.title} - #{message.body}",
             "links" => links_map
           }) do

      Message.changeset(message, %{tags: Enum.uniq(message.tags ++ result["tags"])})
      |> Repo.update()
    else
      e ->
        Logger.error(inspect(e))
        :error
    end
  end
end
