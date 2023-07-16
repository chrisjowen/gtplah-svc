defmodule Ai.PromptExecutor do
  def execute(prompt) do
    result =
      OpenAI.chat_completion(
        model: "gpt-3.5-turbo",
        messages: generate_messages(prompt),
        temperature: prompt.temperature
      )

    with {:ok, response} <- result do

      case prompt.type do
        :json ->
          try_decode_json(response)

        :html ->
          [choice | _] = response.choices
          content = choice["message"]["content"] |> sanitizeResponse(:html)
          {:ok, content}
      end
    end
  end

  defp sanitizeResponse(content, :json) do
    content |> String.replace("```", "")
            |> String.replace("Response:", "")
  end

  defp sanitizeResponse(content, :html) do
    content |> String.replace("```", "")
            |> String.replace("\n", "")
            |> String.replace("\t", "")
  end

  defp try_decode_json(response) do
    [choice | _] = response.choices
    content = choice["message"]["content"] |> sanitizeResponse(:json)
    Jason.decode(content)
  end

  defp generate_messages(prompt) do
    add_message(prompt.goal)
    |> add_message(prompt.hints)
    |> add_message(prompt.format)
    |> add_message(prompt.examples)
    |> add_message(prompt.action)
  end

  defp add_message(content), do: add_message([], content)

  defp add_message(messages, content, role \\ "user") do
    if(is_nil(content)) do
      messages
    else
      messages |> Enum.concat( [%{
        role: role,
        content: content |> String.trim()
      }])
    end
  end
end
