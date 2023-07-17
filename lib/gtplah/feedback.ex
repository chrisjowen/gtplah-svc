defmodule GtpLah.Schema.Feedback do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feedback" do
    field :email, :string
    field :feedback, :string
    field :informed, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(feedback, attrs) do
    feedback
    |> cast(attrs, [:email, :feedback, :informed])
    |> validate_required([:feedback])
  end
end
