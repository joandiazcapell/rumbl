defmodule RumblWeb.AnnotationControllerTest do
  use RumblWeb.ConnCase

  import Rumbl.MultimediaFixtures

  alias Rumbl.Multimedia.Annotation

  @create_attrs %{
    at: 42,
    body: "some body"
  }
  @update_attrs %{
    at: 43,
    body: "some updated body"
  }
  @invalid_attrs %{at: nil, body: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all annotations", %{conn: conn} do
      conn = get(conn, ~p"/api/annotations")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create annotation" do
    test "renders annotation when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/annotations", annotation: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/annotations/#{id}")

      assert %{
               "id" => ^id,
               "at" => 42,
               "body" => "some body"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/annotations", annotation: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update annotation" do
    setup [:create_annotation]

    test "renders annotation when data is valid", %{conn: conn, annotation: %Annotation{id: id} = annotation} do
      conn = put(conn, ~p"/api/annotations/#{annotation}", annotation: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/annotations/#{id}")

      assert %{
               "id" => ^id,
               "at" => 43,
               "body" => "some updated body"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, annotation: annotation} do
      conn = put(conn, ~p"/api/annotations/#{annotation}", annotation: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete annotation" do
    setup [:create_annotation]

    test "deletes chosen annotation", %{conn: conn, annotation: annotation} do
      conn = delete(conn, ~p"/api/annotations/#{annotation}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/annotations/#{annotation}")
      end
    end
  end

  defp create_annotation(_) do
    annotation = annotation_fixture()
    %{annotation: annotation}
  end
end
