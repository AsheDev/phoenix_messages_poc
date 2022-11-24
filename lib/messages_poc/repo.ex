defmodule MessagesPoc.Repo do
  use Ecto.Repo,
    otp_app: :messages_poc,
    adapter: Ecto.Adapters.Postgres
end
