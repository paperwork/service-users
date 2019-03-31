require Logger

defmodule Paperwork.Collections.User do
  @collection "users"
  @privates [:password]
  @enforce_keys []
  @type t :: %__MODULE__{
    id: BSON.ObjectId.t() | nil,
    email: String.t(),
    password: String.t() | nil,
    name: %{
      first_name: String.t(),
      last_name: String.t()
    },
    role: String.t(),
    created_at: DateTime.t(),
    updated_at: DateTime.t(),
    deleted_at: DateTime.t() | nil
  }
  defstruct \
    id: nil,
    email: "",
    password: nil,
    name: %{
      first_name: "",
      last_name: ""
    },
    role: "user",
    created_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now(),
    deleted_at: nil

  use Paperwork.Collections

  @spec show(email :: String.t) :: {:ok, %__MODULE__{}} | {:notfound, nil}
  def show(email) when is_binary(email) do
    collection_find(%__MODULE__{email: email}, :email)
    |> strip_privates
  end

  @spec show(id :: BSON.ObjectId.t) :: {:ok, %__MODULE__{}} | {:notfound, nil}
  def show(%BSON.ObjectId{} = id) do
    show(%__MODULE__{:id => id})
  end

  @spec show(model :: __MODULE__.t) :: {:ok, %__MODULE__{}} | {:notfound, nil}
  def show(%__MODULE__{:id => _} = model) do
    collection_find(model, :id)
    |> strip_privates
  end

  @spec authenticate(model :: __MODULE__.t) :: {:ok, %__MODULE__{}} | {:nok, nil}
  def authenticate(%__MODULE__{:email => email, :password => password} = model) do
    with \
      {:ok, found_user} <- collection_find(model, :email),
      true <- Bcrypt.verify_pass(password, Map.get(found_user, :password)) do
        {:ok, found_user |> strip_privates }
    else
      _ ->
        {:nok, nil}
    end
  end

  @spec list() :: {:ok, [%__MODULE__{}]} | {:notfound, nil}
  def list() do
    %{}
    |> collection_find(true)
    |> strip_privates
  end

  @spec create(model :: __MODULE__.t) :: {:ok, %__MODULE__{}} | {:error, String.t}
  def create(%__MODULE__{} = model) do
    model
    |> set_password_if_given
    |> collection_insert
    |> strip_privates
  end

  @spec update(model :: __MODULE__.t) :: {:ok, %__MODULE__{}} | {:error, String.t}
  def update(%__MODULE__{} = model) do
    model
    |> set_password_if_given
    |> collection_update
    |> strip_privates
  end

  @spec set_password_if_given(model :: __MODULE__.t) :: %__MODULE__{}
  defp set_password_if_given(%__MODULE__{password: password} = model) when is_binary(password) do
    model
    |> Map.put(:password, Bcrypt.hash_pwd_salt(password))
  end

  @spec set_password_if_given(model :: __MODULE__.t) :: %__MODULE__{}
  defp set_password_if_given(%__MODULE__{password: password} = model) when is_nil(password) do
    model
  end
end
