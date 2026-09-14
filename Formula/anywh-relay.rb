class AnywhRelay < Formula
  desc "Headless relay that lets the anywh app talk to a local Claude Code CLI"
  homepage "https://anywh.sh"
  url "https://github.com/anywh-sh/anywh/releases/download/v0.1.4/anywh-relay-0.1.4-darwin-arm64.tar.gz"
  sha256 "7157e7a7b4a33239d31f6773045429cfb0fc6d0295be9216e470490b7883d581"
  license "Apache-2.0"

  depends_on arch: :arm64

  def install
    libexec.install Dir["*"]
  end

  # No `depends_on "node"`: this ships a Node Single Executable
  # Application (built by relay/sea-build/build.mjs) with the
  # runtime bundled in, not a script that needs one installed. A
  # shared "node" dependency has a sharp edge: `brew uninstall
  # anywh-relay` autoremoves Node along with it whenever Node was
  # only ever pulled in as this formula's dependency (not
  # installed on request by the user directly) — even if the user
  # has since started relying on that same Node for unrelated
  # work. Bundling the runtime instead means this formula's
  # presence has zero bearing on whether Node exists on the
  # machine at all.
  #
  # No systemd EnvironmentFile= equivalent here either — Homebrew's
  # service DSL has no such thing — so the "default" profile's
  # config comes in via RELAY_ENV_FILE, a plain environment
  # variable the SEA binary's own entrypoint
  # (relay/sea-build/sea-entry.cjs) applies itself. That
  # indirection exists because Node SEA doesn't process runtime
  # CLI flags the way a plain `node` invocation does: the
  # previous approach here, passing
  # `--env-file-if-exists=...` on the command line, is silently
  # ignored by a SEA binary.
  service do
    run [opt_libexec/"anywh-relay"]
    environment_variables RELAY_ENV_FILE: "#{Dir.home}/.config/anywh/env/default.env"
    working_dir opt_libexec
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

      Uninstalling? Homebrew has no postuninstall hook (unlike apt's
      prerm/postrm), so `brew uninstall`/`brew untap` won't reliably stop
      a launchd service that's still loaded — run this first, in order:
        brew services stop anywh-relay
    CAVEATS
  end

  test do
    assert_path_exists libexec/"anywh-relay"
  end
end
