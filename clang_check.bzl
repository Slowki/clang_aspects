load("@rules_cc//cc:find_cc_toolchain.bzl", "use_cc_toolchain")
load(":common.bzl", "TOOL_WRAPPER", "tool_attr", "tool_wrapper_attr", "wrap_clang_tool")
load(":compile_commands.bzl", "compile_command", "get_compile_headers", "write_compile_command")

def _clang_check_aspect_impl(target, ctx):
    if not ctx.rule.files.srcs:
        return []

    context = target[CcInfo].compilation_context
    args = compile_command(target, ctx, extra_features = ["parseable_fixits"])
    compile_commands_json = write_compile_command(ctx, args)

    output_file = ctx.actions.declare_file(target.label.name + "-clang-check-passed")
    clang_tidy_command = " ".join(wrap_clang_tool(ctx, ctx.executable._clang_check, compile_commands_json) + [file.path for file in ctx.rule.files.srcs])
    ctx.actions.run_shell(
        inputs = depset([compile_commands_json] + ctx.rule.files.srcs, transitive = [get_compile_headers(target, ctx)]),
        tools = depset(ctx.files._clang_check + getattr(ctx.files, TOOL_WRAPPER)),
        outputs = [output_file],
        mnemonic = "ClangCheck",
        command = clang_tidy_command + " && touch " + output_file.path,
    )

    return [
        OutputGroupInfo(clang_tidy = [output_file]),
    ]

clang_check_aspect = aspect(
    implementation = _clang_check_aspect_impl,
    required_providers = [CcInfo],
    fragments = ["cpp"],
    attrs = {
        "_clang_check": tool_attr(default = "@llvm//:bin/clang-check"),
        TOOL_WRAPPER: tool_wrapper_attr(),
    },
    toolchains = use_cc_toolchain(),
)
