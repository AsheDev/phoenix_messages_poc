defmodule MessagesPoc.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :identifier, :string
    has_many :messages, MessagesPoc.Message

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:identifier])
    |> validate_required([:identifier])
  end
end
