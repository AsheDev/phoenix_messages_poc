defmodule MessagesPocWeb.MessagesLive do
  import Ecto.Query, except: [update: 3]
  require Logger
  use MessagesPocWeb, :live_view
  alias MessagesPoc.{Repo,User,Message}
  alias Phoenix.PubSub
  alias MessagesPocWeb.Presence

  @topic "chat" # subscribed clients will receive PubSub messages
  @presence "chat:presence" # subscribed clients will notify others on entry/exit
  @client_names [
    "capybara",
    "elephant",
    "coyote",
    "heron",
    "cockatrice",
    "echidna",
    "swallow",
    "tortoise",
    "bobs-your-uncle",
    "gyarados",
    "meerkat",
    "ferret",
    "anteater",
    "cheetah",
    "gibon",
    "ocelot"
  ]

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to the chat channel messages
      PubSub.subscribe(MessagesPoc.PubSub, @topic)

      # Retrieve 10 most recent messages
      messages = Repo.all(
        Message
        |> order_by(desc: :inserted_at)
        |> limit(10)
        |> preload(:user)
      )
      |> Enum.map(fn(message) ->
           message |> Map.put(:user_identifier, message.user.identifier)
         end)

      # Create a new user
      user_identifier = "#{Enum.random(@client_names)}-#{Enum.random(1000..9999)}"
      {:ok, user} = Repo.insert(%User{identifier: user_identifier})

      # Track the "presence" of this new user
      {:ok, _} = Presence.track(self(), @presence, user_identifier, %{})
      # Subscribe this user's "presence" to the @presence topic
      PubSub.subscribe(MessagesPoc.PubSub, @presence)

      {:ok,
        socket
        |> assign(:initial_load, false)
        |> assign(:submit_active, false)
        |> assign(:active_users, [])
        |> assign(:user_id, user.id)
        |> assign(:user_identifier, user.identifier)
        |> assign(:latest_messages, messages)
        |> assign(:changeset, Message.default(
          %{type: "note", user_identifier: user_identifier, text: ""}))
        |> handle_joins(Presence.list(@presence))
      }
    else
      {:ok,
        socket
        |> assign(:initial_load, true)
        |> assign(:submit_active, false)
        |> assign(:active_users, [%{identifier: "N/A"}])
        |> assign(:user_id, 0)
        |> assign(:user_identifier, "N/A")
        |> assign(:latest_messages, [])
        |> assign(:changeset, Message.default)
      }
    end
  end

  def handle_event("save", %{"message" => params}, socket) do
    user = Repo.get(User, params["user_id"])

    message_data = %{
      type: params["type"],
      text: params["text"],
      user_id: user.id,
      user_identifier: user.identifier
    }
    send(self(), {:save_user_message, message_data})
    PubSub.broadcast(
      MessagesPoc.PubSub,
      @topic,
      {:broadcast_latest, message_data}
    )

    {:noreply,
      socket
      |> assign(:changeset, Message.default)
      |> assign(:submit_active, false)
    }
  end

  def handle_event("validate", %{"message" => params}, socket) do
    changeset = %Message{}
      |> Message.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply,
      socket
      |> assign(:changeset, changeset)
      |> assign(:submit_active, changeset.valid?)
    }
  end

  def handle_info({:save_user_message, message_data}, socket) do
    Repo.insert(
      %Message{
        text: message_data.text,
        type: message_data.type,
        user_id: message_data.user_id
      }
    )
    {:noreply, socket}
  end

  def handle_info({:broadcast_latest, message_data}, socket) do
    {:noreply, update(socket, :latest_messages, &([message_data] ++ &1)) }
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
    {:noreply, socket |> handle_leaves(diff.leaves) |> handle_joins(diff.joins)}
  end

  defp handle_joins(socket, joins) do
    Enum.reduce(joins, socket, fn {user_identifier, _meta}, socket ->
      update(socket, :active_users, &(&1 ++ [%{identifier: user_identifier}]))
    end)
  end

  defp handle_leaves(socket, leaves) do
    Enum.reduce(leaves, socket, fn {user_identifier, _meta}, socket ->
      update(socket, :active_users, &(&1 -- [%{identifier: user_identifier}]))
    end)
  end
end
