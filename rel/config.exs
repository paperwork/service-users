~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"D]v!y;>nR!796v)S,R9J,J!zb^,a;m{:I0u^{2;{{82FV5p9YtUisT&,<4L$KC(^"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"u(t!O,=lO*&9L~1lOngW=f&0|5ZFf/3=M?2**TnE=[}z*/=C=6CTVdU7@!mC^}pE"
  set vm_args: "rel/vm.args"
end

release :paperwork_service_users do
  set version: current_version(:paperwork_service_users)
  set applications: [
    :runtime_tools
  ]
  set config_providers: [
    {Mix.Releases.Config.Providers.Elixir, ["${RELEASE_ROOT_DIR}/etc/config.exs"]}
  ]
  set overlays: [
    {:copy, "config/config.exs", "etc/config.exs"}
  ]
end

