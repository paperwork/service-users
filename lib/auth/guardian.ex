defmodule Auth.Guardian do
  use Guardian, otp_app: :paperwork_service_users

  def subject_for_token(%{id: id}, _claims) do
    {:ok, BSON.ObjectId.encode!(id)}
  end

  def subject_for_token(_, _) do
    {:error, :no_resource_id}
  end

  def resource_from_claims(%{"sub" => sub}) do
    case BSON.ObjectId.decode!(sub) |> Paperwork.Collections.User.show do
      {:ok, user} -> {:ok, Map.from_struct(user)}
      other -> other
    end
  end

  def resource_from_claims(_claims) do
    {:error, :no_claims_sub}
  end
end
