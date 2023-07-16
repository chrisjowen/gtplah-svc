defmodule GtpLah.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :firstname, :string
      add :lastname, :string
      add :email, :string
      add :oauth_provider, :string
      add :oauth_provider_id, :string

      timestamps()
    end
  end
end
