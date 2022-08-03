load("@rules_cc//cc:find_cc_toolchain.bzl", "use_cc_toolchain")
load(":common.bzl", "TOOL_WRAPPER", "tool_attr", "tool_wrapper_attr")
load(":compile_commands.bzl", "compile_command", "get_compile_headers", "write_compile_command")

def _clang_doc_aspect_impl(target, ctx):
    if not ctx.rule.files.srcs:
        return []

    context = target[CcInfo].compilation_context
    args = compile_command(target, ctx)
    compile_commands_json = write_compile_command(ctx, args)

    output_file = ctx.actions.declare_file("all_files.md")
    index_file = ctx.actions.declare_file("index.md")
    markdown_files = [output_file, index_file]

    clang_doc_command = [ctx.executable._clang_doc.path, compile_commands_json.path, "--format=" + ctx.attr.format, "--output={}".format(output_file.dirname)] + [file.path for file in ctx.rule.files.srcs]
    ctx.actions.run(
        inputs = depset([compile_commands_json] + ctx.rule.files.srcs, transitive = [get_compile_headers(target, ctx)]),
        tools = depset(ctx.files._clang_doc + getattr(ctx.files, TOOL_WRAPPER)),
        outputs = markdown_files,
        executable = getattr(ctx.executable, TOOL_WRAPPER),
        mnemonic = "ClangDoc",
        arguments = clang_doc_command,
    )

    return [
        OutputGroupInfo(clang_doc = markdown_files),
    ]

clang_doc_aspect = aspect(
    implementation = _clang_doc_aspect_impl,
    required_providers = [CcInfo],
    fragments = ["cpp"],
    toolchains = use_cc_toolchain(),
    attrs = {
        "format": attr.string(default = "md", values = ["yaml", "md", "html"]),
        TOOL_WRAPPER: tool_wrapper_attr(),
        "_clang_doc": tool_attr(default = "@llvm//:bin/clang-doc"),
    },
)
