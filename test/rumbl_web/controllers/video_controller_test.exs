defmodule RumblWeb.VideoControllerTestuse do
  use RumblWeb.ConnCase, async: true

  import Rumbl.MultimediaFixtures
  import Rumbl.AccountFixtures

  test "requires user authentication on all actions", %{conn: conn} do
    #import import Rumbl.AccountFixtures
    #conn = post(conn, ~p"/videos", video: @create_attrs)
    #assert %{id: id} = redirected_params(conn)

    Enum.each([
      get(conn, ~p"/manage/videos/new"),
      get(conn, ~p"/manage/videos/index"),
      get(conn, ~p"/manage/videos/show/123")
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end
    )
  end

end
