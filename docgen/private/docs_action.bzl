"""Internal documentation processing actions."""

load("@bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory_bin_action")
load(":providers.bzl", "DocsLinkInfo", "DocsProviderInfo")

def docs_action_impl(ctx):
    """Implementation function for docs_action rule.

    Processes documentation files and generates output with proper linking and file dependencies.

    Args:
        ctx: The rule context.

    Returns:
        A list of providers including DefaultInfo and DocsProviderInfo.
    """

    copy_to_directory_bin = ctx.toolchains["@bazel_lib//lib:copy_to_directory_toolchain_type"].copy_to_directory_info.bin

    out_dir = ctx.attr.out or ctx.label.name
    outs = []
    files = [ctx.file.entrypoint] if ctx.file.entrypoint else []
    entrypoint_file_path = ctx.file.entrypoint.short_path if ctx.file.entrypoint else None
    resolved_nav = []

    for key, value in ctx.attr.nav.items():
        nav_element = {}

        if (DocsProviderInfo in key):
            title = value if value and value != "" else key[DocsProviderInfo].title
            entrypoint = key[DocsProviderInfo].entrypoint
            subnav = key[DocsProviderInfo].nav

            if (len(subnav) > 0):
                nav_element[title] = ([entrypoint] if entrypoint else []) + subnav
            elif (entrypoint):
                nav_element[title] = entrypoint
            else:
                nav_element[title] = key.label.name
        elif (DocsLinkInfo in key):
            title = value if value and value != "" else key[DocsLinkInfo].title
            nav_element[title] = key[DocsLinkInfo].url if key[DocsLinkInfo].url != "" else key[DocsLinkInfo].entrypoint if key[DocsLinkInfo].entrypoint != "" else key.label.name
        else:
            nav_element[value] = key.files.to_list()[0].short_path

        resolved_nav.append(nav_element)
        repo_name = ""

        if (DocsProviderInfo in key):
            other_files = key[DocsProviderInfo].files
            repo_name = key[DocsProviderInfo].path
        elif (DocsLinkInfo in key):
            other_files = key[DocsLinkInfo].files
            repo_name = key[DocsLinkInfo].path
        else:
            other_files = key.files.to_list()

        if (repo_name != "" and repo_name != ctx.label.repo_name.replace("+", "")):
            out_folder = ctx.actions.declare_directory(repo_name)

            copy_to_directory_bin_action(
                ctx = ctx,
                copy_to_directory_bin = copy_to_directory_bin,
                name = "_" + repo_name,
                files = other_files,
                dst = out_folder,
                include_external_repositories = ["*"],
                allow_overwrites = True,
            )

            files.append(out_folder)
        else:
            files += other_files

    if ((not ctx.attr.is_index) and len(files) > 0):
        out_folder = ctx.actions.declare_directory(out_dir)

        copy_to_directory_bin_action(
            ctx = ctx,
            copy_to_directory_bin = copy_to_directory_bin,
            name = "_" + ctx.label.name,
            files = files,
            dst = out_folder,
            include_external_repositories = ["*"],
            allow_overwrites = True,
        )

        outs.append(out_folder)

    return [
        DefaultInfo(
            files = depset(outs),
        ),
        DocsProviderInfo(
            path = ctx.attr.rewrite_path or ctx.label.repo_name.replace("+", ""),
            title = ctx.attr.title,
            files = files,
            entrypoint = entrypoint_file_path if entrypoint_file_path else None,
            nav = resolved_nav,
            out_dir = out_dir,
        ),
        DocsLinkInfo(
            path = ctx.attr.rewrite_path or ctx.label.repo_name.replace("+", ""),
            title = ctx.attr.title,
            files = files,
            entrypoint = entrypoint_file_path if entrypoint_file_path else None,
        ),
    ]

docs_action = rule(
    implementation = docs_action_impl,
    doc = """
    Processes documentation files and generates output with proper linking and file dependencies.
    """,
    attrs = {
        "title": attr.string(
            doc = "The title of the navigation element",
        ),
        "entrypoint": attr.label(
            doc = "The entrypoint file for the documentation",
            allow_single_file = True,
        ),
        "srcs": attr.label_list(
            doc = "The files that are part of the documentation",
            allow_files = True,
        ),
        "out": attr.string(
            doc = "The output directory for the documentation",
        ),
        "data": attr.label_list(
            doc = "The data files that are part of the documentation",
        ),
        "deps": attr.label_list(
            doc = "The dependencies of the documentation",
            providers = [DocsProviderInfo],
        ),
        "nav": attr.label_keyed_string_dict(
            doc = "Sub navigation elements",
            allow_files = True,
            providers = [DocsLinkInfo],
        ),
        "rewrite_path": attr.string(
            doc = "The path prefix to rewrite documentation files to",
            default = "",
        ),
        "readme_filename": attr.string(
            doc = "The filename of the README.md file",
            default = "README.md",
        ),
        "readme_content": attr.string(
            doc = "The content of the README.md file",
            default = "",
        ),
        "readme_header_links": attr.label_keyed_string_dict(
            doc = "The links to add to the README.md file",
            allow_files = True,
            providers = [DocsLinkInfo],
        ),
        "is_index": attr.bool(
            doc = "Whether this docs action is the index",
            default = False,
        ),
    },
    toolchains = [
        "@bazel_lib//lib:copy_to_directory_toolchain_type",
        "@bazel_lib//lib:coreutils_toolchain_type",
    ],
)
