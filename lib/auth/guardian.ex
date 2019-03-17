defmodule Auth.Guardian do
  use Guardian, otp_app: :paperwork

  def subject_for_token(%{id: id}, _claims) do
    {:ok, BSON.ObjectId.encode!(id)}
  end

  def subject_for_token(_, _) do
    {:error, :no_resource_id}
  end

  def resource_from_claims(%{"sub" => sub}) do
    Paperwork.Collections.User.show(BSON.ObjectId.decode!(sub))
  end

  def resource_from_claims(_claims) do
    {:error, :no_claims_sub}
  end
end
