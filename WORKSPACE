workspace(name = "clang_aspects")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib",
    sha256 = "710c2ca4b4d46250cdce2bf8f5aa76ea1f0cba514ab368f2988f70e864cfaf51",
    strip_prefix = "bazel-skylib-1.2.1",
    urls = [
        "https://github.com/bazelbuild/bazel-skylib/archive/refs/tags/1.2.1.tar.gz",
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()
