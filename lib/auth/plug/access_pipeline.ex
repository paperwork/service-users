defmodule Auth.Plug.AccessPipeline.Authenticated do
  use Guardian.Plug.Pipeline, otp_app: :paperwork

  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, ensure: true
end

defmodule Auth.Plug.AccessPipeline.Unauthenticated do
  use Guardian.Plug.Pipeline, otp_app: :paperwork

  plug Guardian.Plug.EnsureNotAuthenticated
end
