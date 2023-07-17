defmodule Gtplah.Repo.Migrations.CreateFeedback do
  use Ecto.Migration

  def change do
    create table(:feedback) do
      add :email, :string
      add :feedback, :text
      add :informed, :boolean, default: false, null: false

      timestamps()
    end
  end
end
