load("@bazel_skylib//lib:paths.bzl", "paths")
load("@rules_cc//cc:action_names.bzl", "ACTION_NAMES")
load("@rules_cc//cc:find_cc_toolchain.bzl", "find_cc_toolchain", "use_cc_toolchain")

def _clang_time_trace_aspect_impl(target, ctx):
    # Get the compile commands
    cc_toolchain = find_cc_toolchain(ctx)
    context = target[CcInfo].compilation_context
    features = cc_common.configure_features(ctx = ctx, cc_toolchain = cc_toolchain, requested_features = ctx.features, unsupported_features = ctx.disabled_features)
    variables = cc_common.create_compile_variables(
        cc_toolchain = cc_toolchain,
        feature_configuration = features,
        include_directories = context.includes,
        quote_include_directories = context.quote_includes,
        system_include_directories = context.system_includes,
        framework_include_directories = context.framework_includes,
        preprocessor_defines = depset(transitive = [context.defines, context.local_defines]),
    )
    compiler_flags = cc_common.get_memory_inefficient_command_line(feature_configuration = features, action_name = ACTION_NAMES.cpp_compile, variables = variables)

    output_files = []
    for src in ctx.rule.files.srcs:
        # Declare the trace output file
        trace_output_file = ctx.actions.declare_file(paths.replace_extension(paths.basename(src.short_path), ".json"))
        output_files.append(trace_output_file)

        # The JSON output file location is next to the object file's location - so here we make a throwaway output
        # location based on the source file name
        throwaway_output_path = paths.replace_extension(trace_output_file.path, "")

        # Run the compiler to generate the trace file
        ctx.actions.run(
            inputs = depset(ctx.rule.files.srcs, transitive = [context.headers]),
            tools = depset(transitive = [cc_toolchain.all_files]),
            outputs = [trace_output_file],
            mnemonic = "ClangTimeTrace",
            executable = cc_toolchain.compiler_executable,
            arguments = compiler_flags + ["-ftime-trace", "-c", src.path, "-o", throwaway_output_path],
        )

    # Put the trace files in a `clang_time_trace` output group so we can select them in our .bazelrc
    return [
        OutputGroupInfo(clang_time_trace = output_files),
    ]

clang_time_trace_aspect = aspect(
    implementation = _clang_time_trace_aspect_impl,
    required_providers = [CcInfo],
    fragments = ["cpp"],
    toolchains = use_cc_toolchain(),
)
