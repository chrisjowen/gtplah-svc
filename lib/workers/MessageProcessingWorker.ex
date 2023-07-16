defmodule GtpLah.Workers.MessageProcessingWorker do
  require Logger
  alias GtpLah.Workers.MessageTaggingWorker
  alias Util.StringUtil
  alias GtpLah.Workers.LinkProcessingWorker

  use Oban.Worker,
    queue: :messages,
    max_attempts: 1

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"message" => message}}) do
    message["body"]
    |> StringUtil.extract_urls()
    |> Enum.each(&extract_links(&1, message))

    MessageTaggingWorker.new(%{
      message_id: message["id"]
    })
    |> Oban.insert()

    :ok
  end

  defp extract_links(url, message) do
    Logger.debug("Extracting #{url}")

    LinkProcessingWorker.new(%{
      created_by_id: message["created_by_id"],
      url: url,
      tags: message["tags"],
      message_id: message["id"]
    })
    |> Oban.insert()
  end
end
