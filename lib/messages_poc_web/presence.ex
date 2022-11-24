defmodule MessagesPocWeb.Presence do
  use Phoenix.Presence,
    otp_app: :messages_poc,
    pubsub_server: MessagesPoc.PubSub
end
