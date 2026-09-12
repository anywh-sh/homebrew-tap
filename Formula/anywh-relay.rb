class AnywhRelay < Formula
  desc "Headless relay that lets the anywh app talk to a local Claude Code CLI"
  homepage "https://anywh.sh"
  url "https://github.com/anywh-sh/anywh/releases/download/v0.1.1/anywh-relay-0.1.1-darwin-arm64.tar.gz"
  sha256 "2e21ae104bb6ec0fb8a460bc67bf426198e5c6f8decf25a566f49464ac432b32"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on "node"

  def install
    libexec.install Dir["*"]
  end

  # No systemd EnvironmentFile= here to load the profile's .env —
  # Homebrew's service DSL has no equivalent, so the "default"
  # profile's config has to come in via Node's own
  # --env-file-if-exists instead (same mechanism relay/package.json's
  # start:profile script uses, just spelled out here since there's
  # no npm script wrapper in the installed tarball).
  service do
    run [
      formula_opt_bin("node")/"node",
      "--env-file-if-exists=#{Dir.home}/.config/anywh/env/default.env",
      opt_libexec/"relay/dist/server.js",
    ]
    working_dir opt_libexec/"relay"
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

  test do
    assert_path_exists libexec/"relay/dist/server.js"
  end
end
