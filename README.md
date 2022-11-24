# MessagesPoc

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## About
I wrote this app to learn more about LiveView. It grew quickly from simply
saving a message to PubSub and Presence management. How it works now is a client
will connect, a new User will be created, and the client can begin saving
messages. When the message is saved it will be broadcast to other clients. Also,
when a client connects or disconnects, other clients will be made aware of the
change and the list of users on the page will be updated.

A new user is connected on every refresh as persistance across sessions wasn't
useful for this test.
