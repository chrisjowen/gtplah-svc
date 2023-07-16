defmodule GtpLah.Workers.SchemaUpdatedWorker do
  require Logger

  alias GtpLah.Web.Endpoint

  use Oban.Worker,
    queue: :messages,
    max_attempts: 1

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"type" => type, "entity" => entity, "mode" => mode}}) do
    user_id = Map.get(entity, "created_by_id")

    if(user_id) do
      Logger.info("broadcasting to 'user:#{user_id}' in topic '#{type}:#{mode}'")
      Endpoint.broadcast("user:#{user_id}", "#{type}:#{mode}", entity)
    else
      Logger.info("no user_id found for #{inspect(entity)}")
    end

    Logger.info("Schema updated for #{type} in #{mode} mode")
    :ok
  end
end
