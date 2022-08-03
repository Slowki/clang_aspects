# Clang-related Aspects

This package contains some (hacky) Bazel aspects for working with Clang tooling. It's not production ready - it's just
here to serve as an example for anyone who wants to make similiar aspects.

## Dependencies

- An `@llvm` repo
- bazel_skylib
- rules_cc

## Example `.bazelrc`

```
# Run clang-tidy over the given targets
build:clang-tidy --aspects=@clang_aspects//:clang_tidy.bzl%clang_tidy_aspect
build:clang-tidy --output_groups=clang_tidy

# Run clang-check over the given targets
build:clang-check --aspects=@clang_aspects//:clang_check.bzl%clang_check_aspect
build:clang-check --output_groups=clang_check

# Run clang-doc over the given targets
build:clang-doc --aspects=@clang_aspects//:clang_doc.bzl%clang_doc_aspect
build:clang-doc --output_groups=clang_doc

# Use -ftime-trace to emit `.json` files containing traces of compile times.
build:clang-time-trace --aspects=@clang_aspects//:clang_time_trace.bzl%clang_time_trace_aspect
build:clang-time-trace --output_groups=clang_time_trace
```
