defmodule RumblWeb.VideoChannel do
  use RumblWeb, :channel

  @impl true
  def join("videos:" <> video_id, _payload, socket) do
    :timer.send_interval(5_000, :ping)
    {:ok, socket}
    #{:ok, assign(socket, :video_id, String.to_integer(video_id))}
    #if authorized?(payload) do
    #  {:ok, socket}
    #else
    #  {:error, %{reason: "unauthorized"}}
    #end
  end

  #@impl true
  #def handle_info(:ping, socket) do
  #  count = socket.assigns[:count] || 1
  #  push(socket, "ping", %{count: count})

  #  {:noreply, assign(socket, :count, count + 1)}
  #end


  @impl true
  def handle_in("new_annotation", payload, socket) do
    broadcast!(socket, "new_annotation", %{
      user: %{username: "anon"},
      body: payload["body"],
      at: payload["at"]
    })

    {:reply, :ok, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
