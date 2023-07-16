


# params = %{

#   firstname: "Chris",
#   lastname: "Owen",
#   email: "chris.j.owen@hotmail.co.uk",
#   password: "Letmein123!!!"
#  }

#  alias GtpLah.Schema.IntentMapping
#  alias GtpLah.Repo
#  alias GtpLah.Schema.{User, UserIntegration, Intent, IntentMapping}

# #  user = User.changeset(params)
# #  |> Repo.insert!

# #  UserIntegration.changeset(%{
# #     user_id: user.id,
# #     type: "WhatsApp",
# #     verified: true,
# #     identifier: "+6598073911"
# #  })  |> Repo.insert!


# # %{
# #     name: "Learn To Play Guitar",
# #     tags: ["music", "guitar", "bar-chords", "rock"],
# #     icon_class: "fa-solid fa-guitar text-red-500",
# #     description: "Learn to play guitar like a rock star",
# #     created_by_id: 1
# # } |> Intent.changeset() |> Repo.insert!


# # %{
# #   name: "Build CrowdSolve",
# #   tags: ["startups", "elixir", "idea-generation", "ideation-tools", "mvp"],
# #   icon_class: "fa-solid fa-rocket text-yellow-300",
# #   description: "Dont fuck yourself over",
# #   created_by_id: 1
# # } |> Intent.changeset() |> Repo.insert!


# %{
#   intent_id: 1,
#   message_id: 1
# } |> IntentMapping.changeset() |> Repo.insert!
