defmodule MessagesPoc.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias MessagesPoc.Message

  schema "messages" do
    field :text, :string
    field :type, :string
    belongs_to :user, MessagesPoc.User

    timestamps()
  end

  def emoji(type) do
    case type do
      "note" ->
        "&#128221;"
      "question" ->
        "&#128681;"
      "flag" ->
        "&#10067;"
      nil ->
        ""
    end
  end

  def default(params \\ %{type: "note", user_identifier: "", text: ""}) do
    Message.changeset(%Message{}, params)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:type, :text, :user_id])
    |> validate_required([:type, :text, :user_id])
    |> validate_length(:text, min: 3)
    |> validate_inclusion(:type, ["note", "question", "flag"])
  end
end
