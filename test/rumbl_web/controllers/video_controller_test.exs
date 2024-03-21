defmodule RumblWeb.VideoControllerTestuse do
  use RumblWeb.ConnCase, async: true

  import Rumbl.MultimediaFixtures
  import Rumbl.AccountFixtures

  test "requires user authentication on all actions", %{conn: conn} do
    #conn = post(conn, ~p"/videos", video: @create_attrs)
    #assert %{id: id} = redirected_params(conn)

    Enum.each([
      get(conn, ~p"/manage/videos/new"),
      get(conn, ~p"/manage/videos/index"),
      get(conn, ~p"/manage/videos/123"),
      get(conn, ~p"/manage/videos/123/edit"),
      put(conn, ~p"/manage/videos/123"),
      post(conn, ~p"/manage/videos"),
      delete(conn, ~p"/manage/videos/123"),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end
    )
  end

  describe "with a logged-in user" do
    #setup [:add_login]
    setup %{conn: conn, login_as: username} do
      user = user_fixture(username: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "fulanito"
    test "list all user's videos on index", %{conn: conn, user: user} do
      user_video = video_fixture(user, title: "funny cats")
      other_video = video_fixture(
        user_fixture(username: "other"),
        title: "another video"
      )

      conn = get(conn, ~p"/manage/videos")
      assert html_response(conn, 200) =~ "Listing Videos"
      assert String.contains?(conn.resp_body, user_video.title)
      refute String.contains?(conn.resp_body, other_video.title)
    end
  end

  #With a function from the setup
  #defp add_login (%{conn: conn}) do
  #  user = user_fixture()
  #  conn = assign(conn, :current_user, user)
  #
  # {:ok, conn: conn, user: user}
  #end

end
