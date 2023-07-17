defmodule GtpLah.ConversationServer do
  use GenServer

  alias GtpLah.Chat.FunctionHandler

  ## Missing Client API - will add this later

  def start_link(user_id) do
    name = {:via, Registry, {Registry.Conversations, user_id}}
    GenServer.start_link(__MODULE__, %{}, name: name)
  end

  def send_message(pid, message) do
    input = %{
      role: "user",
      content: message
    }

    GenServer.cast(pid, {:add, input})
    messages = history(pid) |> IO.inspect()

    with {:ok, response} <-
           OpenAI.chat_completion(
             model: "gpt-3.5-turbo",
             messages: generate_messages(messages),
             temperature: 0.4
            #  functions: FunctionHandler.definitions()
           ) do
      [choice | _] = response.choices

      case choice["message"] do
        %{"content" => content} when not is_nil(content) ->
          add_assistant_message(pid, content)
          {:ok, %{content: content}}

        %{"function_call" => function_call} ->
          handle_function_call(pid, function_call)
      end
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp add_assistant_message(pid, content) do
    GenServer.cast(
      pid,
      {:add,
       %{
         role: "assistant",
         content: content
       }}
    )

    content
  end

  defp add_assistant_function(pid, name, content) do
    GenServer.cast(
      pid,
      {:add,
       %{
         role: "function",
         name: name,
         content: Jason.encode!(content)
       }}
    )

    {:ok, summary} = send_message(pid, "provide short summary of results")

    {:ok, %{function: name, results: content, content: summary.content}}
  end

  defp handle_function_call(pid, function_call) do
    with {:ok, result} <- FunctionHandler.handle(function_call) do
      add_assistant_function(pid, function_call["name"], result)
    end
  end

  defp generate_messages(hist) do
    [
      %{
        role: "user",
        content:
          "You are \"Auntie Chan\" you will respond as if you are are local singaporian auntie in your 60's.
          You will be responding with Singlish words and phrases which is a mix of English, Malay, Hokkien, Teochew, Cantonese, Tamil.
          Right now its 2023, covid is over and no masks are required anymore. Your knowaldge cut off was last year so you will not know anything that happened after 2022.

          Feel free to use a lot of emoji to emphesise your points. Be play full, be funny, be sarcastic, be rude a litte, be complimentory sometimes call them pretty etc, be yourself.

          You will always respond in markdown language.
          "
      }
    ] ++ hist.messages
  end

  defp history(pid) do
    GenServer.call(pid, :history)
  end

  ## Defining GenServer Callbacks

  @impl true
  def init(_) do
    {:ok,
     %{
       tokens: 0,
       messages: []
     }}
  end

  @impl true
  def handle_cast({:add, msg}, state) do
    # tokens = calculate_tokens(state.messages)
    {:noreply, Map.put(state, :messages, state.messages ++ [msg])}
  end

  @impl true
  def handle_call(:history, _from, state) do
    {:reply, state, state}
  end
end
