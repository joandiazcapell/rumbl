defmodule RumblWeb.VideoChannel do
  alias Rumbl.Multimedia
  alias Rumbl.Accounts
  use RumblWeb, :channel

  @impl true
  def join("videos:" <> video_id, _payload, socket) do
    #video_id = String.to_integer(video_id)
    #video = Multimedia.get_video!(video_id)

    #annotations =
    #  video
    # |> Multimedia.list_anotations()
    #  |> Phoenix.

    {:ok, assign(socket, :video_id, String.to_integer(video_id))}
  end

  @impl true
  def handle_in(event, payload, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    handle_in(event, payload, user, socket)
  end

  def handle_in("new_annotation", payload, user, socket) do
    case Multimedia.annotate_video(user, socket.assigns.video_id, payload) do
      {:ok, annotation} ->
        broadcast!(socket, "new_annotation", %{
          id: annotation.id,
          user: RumblWeb.UserJSON.show(%{user: user}),
          body: annotation.body,
          at: annotation.at
        })
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end
