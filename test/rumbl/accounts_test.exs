defmodule Rumbl.AccountsTest do
  alias Hex.API.User
  use Rumbl.DataCase, async: true

  alias Rumbl.Accounts
  alias Rumbl.Accounts.User

  describe "register_user/1" do
    @valid_attrs %{
      name: "User",
      username: "anna",
      password: "secret"
    }
    @invalid_attrs %{}

  test "with valid data inserts user" do
    assert {:ok, %User{id: id} = user} = Accounts.register_user(@valid_attrs)
    assert user.name == "User"
    assert user.username == "anna"
    assert [%User{id: ^id}] = Accounts.list_users()
  end

  test "with invalid data does not insert user" do
    assert {:error, _changeset} = Accounts.register_user(@invalid_attrs)
    assert Accounts.list_users() == []
  end

  test "enforces unique username" do
    assert {:ok, %User{id: id}} = Accounts.register_user(@valid_attrs)
    assert {:error, changeset} = Accounts.register_user(@valid_attrs)

    assert %{username: ["has already been taken"]} = errors_on(changeset)

    assert [%User{id: ^id}] = Accounts.list_users()
  end

  test "does not accept long usernames" do
    attrs = Map.put(@valid_attrs, :username, String.duplicate("a", 30))
    {:error, changeset} = Accounts.register_user(attrs)

    assert %{username: ["should be at most 20 character(s)"]} = errors_on(changeset)
    assert Accounts.list_users() == []
  end

  test "requires password to be at least 6 chars long" do
    attrs = Map.put(@valid_attrs, :password, "12345")
    {:error, changeset} = Accounts.register_user(attrs)

    assert %{password: ["should be at least 6 character(s)"]} = errors_on(changeset)
    assert Accounts.list_users() == []
  end
end

  describe "authenticate_by_username_and_password/2" do
    import Rumbl.AccountFixtures

    @pass "123456"

    setup do
      {:ok, user: user_fixture(password: @pass)}
    end

    test "returns user with correct password", %{user: user} do
      assert {:ok, auth_user} = Accounts.authenticate_by_username_and_password(user.username, @pass)

      assert auth_user.id == user.id
    end

    test "returns unauthorized error with invalid password", %{user: user} do
      assert {:error, :unauthorized} = Accounts.authenticate_by_username_and_password(user.username, "badpass")
    end

    test "returns not found error with no matching user for email" do
      assert {:error, :not_found} = Accounts.authenticate_by_username_and_password("unknownuser", @pass)
    end
  end
end
