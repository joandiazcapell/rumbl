defmodule RumblWeb.VideoChannel do
  use RumblWeb, :verified_routes
  use RumblWeb, :channel

  alias Rumbl.Multimedia
  alias Rumbl.Accounts

  @impl true
  def join("videos:" <> video_id, _payload, socket) do
    video_id = String.to_integer(video_id)
    video = Multimedia.get_video!(video_id)

    annotations =
      video
      |> Multimedia.list_anotations()

    annotations_json = RumblWeb.AnnotationJSON.index(%{annotations: annotations})
    #annotations = ~p"/api/annotations/#{video_id}"

    {:ok, %{annotations: annotations_json}, assign(socket, :video_id, video_id)}
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
          #user: RumblWeb.UserJSON.show(%{user: user}),
          user: ~p"/api/users/#{user}",
          body: annotation.body,
          at: annotation.at
        })
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end
