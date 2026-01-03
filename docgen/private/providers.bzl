"""Providers for documentation rules."""

DocsProviderInfo = provider(
    doc = "Provider to specify docs information, such as files and navigation title",
    fields = {
        "path": "The path of the documentation",
        "title": "The title of the navigation element",
        "entrypoint": "The entrypoint file for the documentation",
        "files": "The files that are part of the documentation",
        "nav": "The sub navigation elements",
        "out_dir": "The output directory for the documentation",
    },
)

DocsLinkInfo = provider(
    doc = "Provider to specify a link to docs (external URL or internal path)",
    fields = {
        "path": "The path of the documentation",
        "title": "The title of the navigation element",
        "url": "The URL of the navigation element",
        "entrypoint": "The entrypoint file for the documentation",
        "files": "The files that are part of the documentation",
    },
)

MarkdownInfo = provider(
    doc = "Provider for markdown processing results",
    fields = {
        "file": "The generated markdown file",
        "entrypoint": "The entrypoint path for the markdown file",
        "files": "All files related to this markdown processing",
    },
)
