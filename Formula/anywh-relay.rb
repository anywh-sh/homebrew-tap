class AnywhRelay < Formula
  desc "Headless relay that lets the anywh app talk to a local Claude Code CLI"
  homepage "https://anywh.sh"
  version "0.1.1"
  url "https://github.com/anywh-sh/anywh/releases/download/v0.1.1/anywh-relay-0.1.1-darwin-arm64.tar.gz"
  sha256 "074fe559dd7ebf43bd7bb032c21f29620f089660f1ad4318d110f9c7ece6274e"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on "node"

  def install
    libexec.install Dir["*"]
  end

  service do
    run [Formula["node"].opt_bin/"node", libexec/"relay/dist/server.js"]
    working_dir libexec/"relay"
    environment_variables ANYWH_PROFILE: "default"
    keep_alive true
    log_path var/"log/anywh-relay.log"
    error_log_path var/"log/anywh-relay.error.log"
  end

  def caveats
    <<~CAVEATS
      Create the "default" profile once before starting the service:
        #{opt_libexec}/infra/systemd/add-profile.sh default --mode dev --relay-host <this-machine's-tailscale-or-lan-ip>

      Then:
        brew services start anywh-relay
    CAVEATS
  end
end
