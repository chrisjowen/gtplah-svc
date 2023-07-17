defmodule GtpLah.UserChannel do
  use Phoenix.Channel
  # alias Phoenix.Socket.Broadcast
  alias GtpLah.ConversationServer

  def join("user:" <> user_id, _params, socket) do

    Registry.lookup(Registry.Conversations, user_id)
    |> IO.inspect()

    pid =
      case Registry.lookup(Registry.Conversations, user_id) do
        [] ->
          {:ok, pid} = ConversationServer.start_link(user_id)
          pid

        [{pid, _}] ->
          pid
      end

    IO.inspect("Found pid #{inspect(pid)}")

    {:ok,
     socket
     |> assign(:conversation, pid)}
  end

  def handle_in("message:client:send", payload, socket) do
    pid = socket.assigns[:conversation]

    try do
      with {:ok, response} = ConversationServer.send_message(pid, payload["message"]) do
        broadcast!(socket, "message:server:send", response)
      else
        {:error, error} ->  broadcast!(socket, "message:server:send", %{content: "Sorry, I had a problem responding to you. Auntie old you know. Please retry"})
      end
    rescue
      _ -> broadcast!(socket, "message:server:send", %{content: "Sorry, I had a problem responding to you. Auntie old you know. Please retry"})
    end


    {:noreply, socket}
  end
end
