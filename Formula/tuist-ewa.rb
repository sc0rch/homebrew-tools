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
    (libexec/"Frameworks").mkpath

    libexec.install "tuist-ewa"
    libexec.install "Templates"

    libexec.install "ProjectDescription.framework"
    (libexec/"Frameworks").install "ProjectDescription.framework"

    if Pathname("ProjectDescription.framework.dSYM").exist?
      libexec.install "ProjectDescription.framework.dSYM"
    end

    if Pathname("vendor").exist?
      libexec.install "vendor"
    end

    (bin/"tuist-ewa").write <<~EOS
      #!/bin/bash
      export TUIST_FRAMEWORK_SEARCH_PATHS="#{libexec}/Frameworks"
      export TUIST_TEMPLATES_PATH="#{libexec}"
      exec "#{libexec}/tuist-ewa" "$@"
    EOS
    chmod 0755, bin/"tuist-ewa"
  end

  test do
    system bin/"tuist-ewa", "--help"
  end
end
