defmodule Paperwork.Auth.Session do
  use Joken.Config

  def get(%Plug.Conn{}=conn) do
    conn.private[:paperwork_user]
  end

  def token_config, do: default_claims(default_exp: 60 * 60, iss: "Paperwork", aud: "paperwork-client")

  def create(%Paperwork.Collections.User{}=user) do
    signer = Joken.Signer.parse_config(:hs512)
    with \
      {:ok, claims} <- Joken.generate_claims(token_config(), %{"sub" => BSON.ObjectId.encode!(user.id), "typ" => "access"}),
      {:ok, jwt, claims} <- Joken.encode_and_sign(claims, signer) do
        {:ok, jwt, claims}
    else
      _ ->
        {:error, nil}
    end
  end
end
