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
    scratch = buildpath/"swift-build"
    base_args = [
      "swift", "build",
      "--disable-sandbox",
      "--replace-scm-with-registry",
      "--scratch-path", scratch,
      "-c", "release",
    ]
    system(*(base_args + ["--product", "tuist"]))

    %w[ProjectDescription ProjectAutomation].each do |product|
      system(*(base_args + ["--product", product]))
    end

    build_products = Pathname.new(
      Utils.safe_popen_read(
        "swift", "build",
        "--disable-sandbox",
        "--replace-scm-with-registry",
        "--scratch-path", scratch,
        "--show-bin-path",
        "-c", "release"
      ).strip
    )

    bin.install build_products/"tuist"

    architecture_output = Pathname.glob(scratch/"*-apple-macosx/release").first
    odie "Unable to locate release build output in #{scratch}" unless architecture_output

    frameworks_path = libexec/"Frameworks"
    frameworks_path.mkpath

    {
      "ProjectDescription" => %w[swiftmodule swiftdoc swiftsourceinfo abi.json],
      "ProjectAutomation" => %w[swiftmodule swiftdoc swiftsourceinfo abi.json],
    }.each do |product, extensions|
      dylib_path = architecture_output/"lib#{product}.dylib"
      cp dylib_path, frameworks_path

      modules_dir = architecture_output/"Modules"
      Pathname.glob("#{modules_dir}/#{product}.{#{extensions.join(",")}}").each do |module_file|
        cp module_file, frameworks_path
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
