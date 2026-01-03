"""Rules for generating MkDocs configuration files."""

load(":providers.bzl", "DocsProviderInfo")

def _mkdocs_config_impl(ctx):
    docs = ctx.attr.docs[DocsProviderInfo]

    base = ctx.file.mkdocs_base
    out = ctx.actions.declare_file(ctx.label.name + ".mkdocs.yml")

    root_nav_folder = ctx.attr.root_nav_folder
    if (root_nav_folder and (not root_nav_folder.endswith("/"))):
        root_nav_folder = root_nav_folder + "/"

    nav_json = json.encode(docs.nav)
    nav = nav_json.replace(root_nav_folder, "") if root_nav_folder else nav_json
    docs_path = docs.out_dir

    # Write the mkdocs.yml file
    ctx.actions.run_shell(
        inputs = [base],
        outputs = [out],
        mnemonic = "GenerateMkdocsConfig",
        progress_message = "Generating mkdocs.yml from %s" % base.short_path,
        command = "(echo 'nav: {nav}'; cat {input}) | sed 's|BAZEL_DOCS_DIR_PLACEHOLDER|{docs_path}|g' > {output}".format(
            nav = nav,
            docs_path = docs_path.replace("|", "\\|"),
            input = base.path,
            output = out.path,
        ),
    )

    return [
        DefaultInfo(
            files = depset([out]),
        ),
    ]

mkdocs_config = rule(
    doc = """Generate an MkDocs configuration file from a template.

    This rule takes a base MkDocs YAML configuration template and merges it with
    the navigation structure from a docs target. The result is a complete mkdocs.yml
    file that can be used with mkdocs_build or mkdocs_serve.

    Example:
        mkdocs_config(
            name = "mkdocs_config",
            docs = ":docs",
            mkdocs_base = "mkdocs.tpl.yaml",
        )

    The base template should contain all MkDocs settings except the 'nav' section,
    which will be automatically generated from the docs target.
    """,
    implementation = _mkdocs_config_impl,
    attrs = {
        "title": attr.string(
            doc = "The title of the site",
        ),
        "docs": attr.label(
            doc = "The docs to include in the site",
            providers = [DocsProviderInfo],
        ),
        "mkdocs_base": attr.label(
            doc = "The base mkdocs.yml file",
            allow_single_file = [".yaml", ".yml"],
            mandatory = True,
        ),
        "root_nav_folder": attr.string(
            doc = "The root nav folder",
            default = "",
        ),
    },
)
