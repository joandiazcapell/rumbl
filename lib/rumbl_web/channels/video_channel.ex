defmodule RumblWeb.VideoChannel do
  use RumblWeb, :channel

  @impl true
  def join("videos:" <> video_id, payload, socket) do
    #:timer.send_interval(5_000, :ping)
    #{:ok, assign(socket, :video_id, String.to_integer(video_id))}
    {:ok, socket}
  end

  @impl true
  def handle_in("new_annotation", payload, socket) do
    broadcast!(socket, "new_annotation", %{
      user: %{username: "anon"},
      body: payload["body"],
      at: payload["at"]
    })

    {:reply, :ok, socket}
  end
end
