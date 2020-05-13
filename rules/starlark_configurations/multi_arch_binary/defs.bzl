def _transition_impl(settings, attr):
    _ignore = [settings, attr]

    # Return a dict of dicts. The values are the updates to the configuration.
    # The keys are arbitrary helpful strings that can be used to access the split
    # targets in the rule context
    #
    # Returning a dict of dicts creates a "split transition", which transitions
    # the dep it's attached to to more than one configuration creating multiple
    # configured targets. For more info on "split" transitions:
    # https://docs.bazel.build/versions/master/skylark/config.html#defining-12-transitions
    return {
        "x86-platform": {"//command_line_option:cpu": "x86"},
        "armeabi-v7a-platform": {"//command_line_option:cpu": "armeabi-v7a"}
	}


fat_transition = transition(
    implementation = _transition_impl,
    inputs = [],
    outputs = ["//command_line_option:cpu"]
)

def _rule_impl(ctx):
    # Access the split dependencies via `ctx.split_attr.<split-attr-name>`
    tools = ctx.split_attr.tool
    # The values of `x86_dep` and `armeabi-v7a_dep` here are regular
    # dependencies with providers.
    x86_dep = tools['x86-platform']
    armeabi_v7a_dep = tools['armeabi-v7a-platform']
    print("transitioned deps: ")
    print(ctx.split_attr.tool)
    return []

foo_binary = rule(
  implementation = _rule_impl,
  attrs = {
    "tool": attr.label(cfg = fat_transition),
    # This attribute is required to use starlark transitions. It allows 
    # whitelisting usage of this rule. For more information, see
    # https://docs.bazel.build/versions/master/skylark/config.html#user-defined-transitions
    '_whitelist_function_transition': attr.label(
        default = '@bazel_tools//tools/whitelists/function_transition_whitelist',
    )
  }
)

def _impl(ctx):
    return []

simple = rule(_impl)