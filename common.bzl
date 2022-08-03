def rule_kind(ctx):
    """Get the kind of a rule."""
    return ctx.rule.kind

def has_cc_info(target):
    """Check whether or not a Target has `CcInfo`."""
    return CcInfo in target

def tool_attr(**kwargs):
    return attr.label(executable = True, allow_single_file = True, cfg = "exec", **kwargs)

TOOL_WRAPPER = "_tool_wrapper"

def tool_wrapper_attr():
    return attr.label(executable = True, default = "@clang_aspects//:tool_wrapper", cfg = "exec")

def wrap_clang_tool(ctx, clang_tool, compile_commands):
    return [getattr(ctx.executable, TOOL_WRAPPER).path, clang_tool.path, compile_commands.path]
