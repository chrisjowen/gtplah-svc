defmodule GtpLah.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :firstname, :string
    field :lastname, :string
    field :email, :string
    field :oauth_provider, :string
    field :oauth_provider_id, :string
    field :password, Comeonin.Ecto.Password
    field :salt, :string, default: Ecto.UUID.generate()
    field :clear_password, :string, virtual: true
    timestamps()
  end

  @doc false
  def changeset(attrs), do: changeset(%__MODULE__{}, attrs)

  def changeset(user, attrs) do
    attrs = maybe_add_clear_password(attrs)
    required = [:firstname, :lastname,  :email]
    additional = [
      :password,
      :salt,
      :clear_password
    ]
    user
    |> cast(attrs, required ++ additional)
    |> maybe_validate_password(user, attrs)
    |> validate_required(required)
  end

  defp maybe_validate_password(changeset, user, attrs) do
    if((user.oauth_provider_id == nil && attrs["oauth_provider_id"] == nil) ||  attrs["password"] != nil ) do
      changeset
      |> validate_length(:clear_password, min: 6)
      |> validate_required([:password, :salt])
    else
      changeset
    end
  end

  defp maybe_add_clear_password(%{"password" => password} = attrs) do
    attrs |> Map.put("clear_password", password)
  end
  defp maybe_add_clear_password(attrs), do: attrs

end
