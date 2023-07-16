defmodule Ai.PromptBuilder do
  defmodule Prompt do
    defstruct type: :json,
              goal: nil,
              format: nil,
              hints: nil,
              action: nil,
              examples: nil,
              limit: 3000,
              temperature: 0.7
  end

  def new(temperature \\ 0.7) do
    %Prompt{
      temperature: temperature
    }
  end

  def with_type(prompt, type) do
    Map.put(prompt, :type, type)
  end

  def with_goal(prompt, goal) do
    Map.put(prompt, :goal, goal)
  end

  def with_format(prompt, format) do
    Map.put(prompt, :format, format)
  end

  def with_hints(prompt, hints) do
    Map.put(prompt, :hints, hints)
  end

  def with_examples(prompt, examples) do
    Map.put(prompt, :examples, examples)
  end

  def with_action(prompt, action) do
    Map.put(prompt, :action, action)
  end

  def build(prompt) do
    if(is_nil(prompt.goal) or is_nil(prompt.action)) do
      {:error, "Goal and action  required"}
    else
      with {:ok, format} <- build_format(prompt),
           {:ok, hints} <- build_hints(prompt),
           {:ok, action} <- build_action(prompt) do
        {:ok,
         prompt
         |> Map.put(:format, format)
         |> Map.put(:hints, hints)
         |> Map.put(:action, action)}
      else
        _ ->
          {:error, "Failed to build prompt"}
      end
    end
  end

  defp build_hints(prompt) do
    hints = """
    Below in the tripple ticks are some hints to help you complete this task:

    ```
    #{prompt.hints}
    ```
    """
    {:ok, hints}
  end

  defp build_action(prompt) do
    {:ok, prompt.action}
  end

  defp build_format(prompt) do
    case prompt.type do
      :json -> prompt |> build_json_format()
      :html -> prompt |> build_html_format()
      :plain_text -> {:ok, prompt}
    end
  end

  defp build_json_format(prompt) do
    if(is_nil(prompt.format)) do
      {:error, "Format required for type :json"}
    else
      response =
        """
        When performing this task:

          - The output should be a VALID JSON OBJECT and NOTHING ELSE!
          - Ensure all json keys are surrounded by speech marks i.e. {"name": "chris"} not {name: "chris"}
          - Check the WHOLE response is parsable with javascript JSON.parse(), if not fix it
          - Do not add any commentory or desciption before the json, just return the raw json

        The format of the response is sepcified below in the tripple backticks:
        ```
        #{prompt.format}
        ```

        If you are unable to generate the response, return an error json in the format  sepcified below in following tripple backticks:

        ```
        {"error": "Reason for error"}
        ```

        Remember to remove the tripple backticks from the response  and remember to only return the JSON portion of the response.
        """


      {:ok, response}
    end
  end

  def build_html_format(prompt) do
    response =
      """
      The output format MUST be 100% valid HTML it should:

        - Only return the HTML inside the <body> not the <head> or <html> tags
        - It should not contain any comments new '\n' or '\t'
        - The output should be a VALID HTML with text not enclosed in any tags.
        - It should be as compact as possible.
        - It should NOT contain any comments, or \n new line breaks
        - Valid text tags are P, H1, H2, H3
        - Valid list tags are UL and OL
        - If required you may also use <Code> and <Pre> and <Quote> tags
        - It May also return assosiated table tags if you have tablur data.
      """

    case prompt.format do
      nil ->
        {:ok, response}

      format ->
        additional =
          """
            Inside the tripple backticks is format of the output you should return:
            ```
            #{format}
            ```
          """

        {:ok, response <> additional}
    end
  end
end
