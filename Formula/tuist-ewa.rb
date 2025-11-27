# frozen_string_literal: true

require "pathname"

class TuistEwa < Formula
  desc "Tuist fork with skipPackageResolution flag"
  homepage "https://github.com/sc0rch/tuist"
  url "https://github.com/sc0rch/tuist/archive/refs/heads/homebrew-4.109.1.tar.gz"
  version "4.109.1-ewa"
  sha256 "11d02d082ed1fe6a037e2efd5c2f7f5acdbc7f40dcd720f6734e6b035d5ffe0a"
  license "Apache-2.0"

  depends_on xcode: ["15.0", :build]

  def install
    ENV["SWIFT_BUILD_ENABLE_SANDBOX"] = "0"
    system "swift", "build", "--disable-sandbox", "--replace-scm-with-registry", "--product", "tuist", "-c", "release"
    bin.install ".build/release/tuist"

    frameworks_path = libexec/"Frameworks"
    frameworks_path.mkpath

    dylibs = Pathname.glob(".build/**/*ProjectDescription*.dylib")
    frameworks = Pathname.glob(".build/**/*ProjectDescription*.framework")

    (dylibs + frameworks).each do |path|
      destination = frameworks_path/path.basename
      if path.directory?
        cp_r path, destination
      else
        cp path, destination
      end
    end

    (bin/"tuist-ewa").write <<~EOS
      #!/bin/bash
      export TUIST_FRAMEWORK_SEARCH_PATHS="#{frameworks_path}"
      exec "#{bin}/tuist" "$@"
    EOS
    chmod 0755, bin/"tuist-ewa"
  end

  test do
    system bin/"tuist-ewa", "--help"
  end
end
