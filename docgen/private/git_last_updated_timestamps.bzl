load("@bazel_lib//lib:run_binary.bzl", "run_binary")

def git_last_updated_timestamps(
    name,
    git_dir = ".git",
    srcs = [],
    out = "git-timestamps.json",
    filter_extensions = ["md", "rst", "txt"],
    **kwargs
):
    run_binary(
        name = name,
        srcs = native.glob([git_dir + "/**"]) + srcs,
        tool = "@jacobshirley_rules_docgen//docgen/private/sh:git-last-updated-timestamps.sh",
        outs = [out],
        args = [
            "--filter-extensions",
            ",".join(filter_extensions),
            "--output",
            "$(location " + out + ")",
            "--git-dir",
            git_dir,
        ],
        mnemonic = "GitLastUpdatedTimestamps",
        **kwargs
    )