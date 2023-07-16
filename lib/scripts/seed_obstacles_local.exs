alias GtpLah.Schema.Problem
alias GtpLah.Schema.Obstacle
alias GtpLah.Repo

defmodule Seeder do
  def execute() do
    Repo.all(Problem)
    |> Repo.preload([:sector])
    |> Enum.each(&generate_obstacles/1)
  end

  def generate_obstacles(problem) do
    Task.async(fn ->
      baseUrl = "http://127.0.0.1:5173"


      token =
        "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJwcm9ibGVtX3NlcnZpY2UiLCJleHAiOjE2ODg3MTkwNzIsImlhdCI6MTY4NjI5OTg3MiwiaXNzIjoicHJvYmxlbV9zZXJ2aWNlIiwianRpIjoiMTBmNGIzNGEtNWFkZC00Y2ZjLTg1NWQtYjg4ZDFkOTg0YWIxIiwibmJmIjoxNjg2Mjk5ODcxLCJzdWIiOiIxIiwidHlwIjoiYWNjZXNzIn0.2jeUnFNcrFytrhFfU0ono-rf5fZVa0QpPt0YIwqL9TwueJ9blsdx8JqUztzf4U5bmsXg_xYOSNiwEPwUmkgNXA"

      headers = [Authorization: "Bearer #{token}", "Content-Type": "application/json"]

      with {:ok, response} <-
             HTTPoison.post("#{baseUrl}/api/ai/problem/#{problem.id}/obstacles", "{}", headers,
               timeout: 50_000,
               recv_timeout: 50_000
             ),
           {:ok, body} <- Jason.decode(response.body) do
        body["obstacles"]
        |> Enum.each(fn obstacle ->

          Obstacle.changeset(%Obstacle{}, %{
            problem_id: problem.id,
            description: obstacle["obstacle"],
            questions: obstacle["questions"],
            hint: obstacle["solutionHint"],
            tags: obstacle["types"]
          })
          |> Repo.insert!()
        end)
      end
    end)
  end
end

Seeder.execute()
