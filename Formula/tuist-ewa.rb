# frozen_string_literal: true

require "pathname"

class TuistEwa < Formula
  desc "Tuist fork"
  homepage "https://github.com/sc0rch/tuist-ewa"
  url "https://github.com/sc0rch/tuist-ewa/releases/download/4.118.1-ewa.1/tuist.zip"
  version "4.118.1-ewa.1"
  sha256 "438381a21d7756846bfcec04668ded2a324cd26116315e3a911b29ce68f4fffa"
  license "Apache-2.0"

  def install
    bin.install "tuist"

    lib.install "ProjectDescription.framework"

    share.install "Templates"

    if Pathname("vendor").exist?
      libexec.install "vendor"
    end

    (bin/"tuist-ewa").write <<~EOS
      #!/bin/bash
      exec "#{bin}/tuist" "$@"
    EOS
    chmod 0755, bin/"tuist-ewa"
  end

  test do
    system bin/"tuist-ewa", "--help"
  end
end
