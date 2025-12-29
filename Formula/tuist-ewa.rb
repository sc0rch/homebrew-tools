# frozen_string_literal: true

require "pathname"

class TuistEwa < Formula
  desc "Tuist fork"
  homepage "https://github.com/sc0rch/tuist-ewa"
  url "https://github.com/sc0rch/tuist-ewa/releases/download/4.118.1-ewa.2/tuist.zip"
  version "4.118.1-ewa.2"
  sha256 "3ceb4c5bcc506cc9e47ded8d34f9d4c073ce955ab74d72db1e04314db6285412"
  license "Apache-2.0"

  def install
    (libexec/"Frameworks").mkpath

    libexec.install "tuist-ewa"
    libexec.install "Templates"

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
