load("@rules_cc//cc:action_names.bzl", "ACTION_NAMES")
load("@rules_cc//cc:find_cc_toolchain.bzl", "find_cc_toolchain")

def get_compile_headers(target, ctx):
    """Get a depset of headers needed to compile a target."""
    cc_info = target[CcInfo]
    cc_toolchain = find_cc_toolchain(ctx)

    context = cc_info.compilation_context
    return depset(transitive = [cc_toolchain.all_files, context.headers])

def compile_command(target, ctx, extra_features = []):
    """Generate a command to compile `target`."""
    cc_info = target[CcInfo]
    cc_toolchain = find_cc_toolchain(ctx)

    context = cc_info.compilation_context

    features = cc_common.configure_features(ctx = ctx, cc_toolchain = cc_toolchain, requested_features = extra_features + ctx.features, unsupported_features = ctx.disabled_features)
    variables = cc_common.create_compile_variables(
        cc_toolchain = cc_toolchain,
        feature_configuration = features,
        include_directories = context.includes,
        quote_include_directories = context.quote_includes,
        system_include_directories = context.system_includes,
        framework_include_directories = context.framework_includes,
        preprocessor_defines = depset(transitive = [context.defines, context.local_defines]),
    )
    return cc_common.get_memory_inefficient_command_line(feature_configuration = features, action_name = ACTION_NAMES.cpp_compile, variables = variables)

def write_compile_command(ctx, command):
    """Write a compile commands file.

    See https://clang.llvm.org/docs/JSONCompilationDatabase.html

    Args:
        ctx (ctx): A context object.
        command (str): A compile command.
    """
    compile_commands_file = ctx.actions.declare_file(ctx.label.name + "/compile_commands.json")
    compile_commands = []
    for file in ctx.rule.files.srcs:
        entry = {
            "arguments": command + ["-c", file.path],
            "directory": "PWD_SIGIL",
            "file": file.path,
        }
        relative_entry = dict(entry)
        relative_entry["file"] = file.short_path
        workspace_prefix_entry = dict(entry)
        workspace_prefix_entry["file"] = ctx.workspace_name + "/" + file.path
        compile_commands.append(entry)

    compile_commands = ctx.actions.write(
        output = compile_commands_file,
        content = json.encode(compile_commands),
        is_executable = False,
    )
    return compile_commands_file
