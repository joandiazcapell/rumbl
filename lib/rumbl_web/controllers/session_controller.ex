defmodule RumblWeb.SessionController do
  use RumblWeb, :controller

  def new(conn, _) do
    render(conn, :new)
  end

  def create(conn, %{"session" => %{"username" => username, "password" => password}}) do
    IO.puts("+++")
    IO.inspect(conn)
    IO.puts("+++")
    IO.inspect(username)
    case Rumbl.Accounts.authenticate_by_username_and_password(username, password) do
      {:ok, user} ->
        conn
        |> RumblWeb.Plugs.Auth.login(user)
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: ~p"/users")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render(:new)
    end
  end

end
