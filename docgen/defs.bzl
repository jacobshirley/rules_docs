load("//docgen/private:docs.bzl", _docs = "docs")
load("//docgen/private:docs_add_last_updated.bzl", _docs_add_last_updated = "docs_add_last_updated")
load("//docgen/private:mkdocs_build.bzl", _mkdocs_build = "mkdocs_build")
load("//docgen/private:mkdocs_config.bzl", _mkdocs_config = "mkdocs_config")
load("//docgen/private:git_last_updated_timestamps.bzl", _git_last_updated_timestamps = "git_last_updated_timestamps")

docs = _docs
docs_add_last_updated = _docs_add_last_updated
mkdocs_build = _mkdocs_build
mkdocs_config = _mkdocs_config
git_last_updated_timestamps = _git_last_updated_timestamps