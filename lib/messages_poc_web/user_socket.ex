defmodule MyAppWeb.UserSocket do
  use Phoenix.Socket
  require Logger
  
  # ...

  def on_connect(pid, user_id) do
    # Log user_id connected, increase gauge, etc.
    Logger.log(:debug, user_id)
    Logger.log(:debug, ">>>> ONE")
    monitor(pid, user_id)
  end

  def on_disconnect(user_id) do
    # Log user_id disconnected, decrease gauge, etc.
    Logger.log(:debug, user_id)
    Logger.log(:debug, ">>>> TWO")
  end

  defp monitor(pid, user_id) do
    Task.Supervisor.start_child(MyApp.TaskSupervisor, fn ->
      Process.flag(:trap_exit, true)
      ref = Process.monitor(pid)

      receive do
        {:DOWN, ^ref, :process, _pid, _reason} ->
          on_disconnect(user_id)
      end
    end)
  end
end
