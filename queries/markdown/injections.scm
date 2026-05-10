; Override nvim-treesitter's markdown/injections.scm.
;
; The plugin (master branch) ships a `#set-lang-from-info-string!` directive
; whose handler still uses the pre-nvim-0.11 API where `match[capture_id]`
; was a single TSNode. In 0.11+ it's a TSNode[] array, which makes the
; handler crash with `attempt to call method 'range' (a nil value)` when
; opening any markdown file with fenced code blocks.
;
; This is a copy of the native nvim runtime query — it captures the language
; node directly as @injection.language, which is supported out of the box and
; needs no custom directive. Drop this override once nvim-treesitter master
; ships a fix (or we migrate to its `main` branch).

(fenced_code_block
  (info_string
    (language) @injection.language)
  (code_fence_content) @injection.content)

((html_block) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined)
  (#set! injection.include-children))

((minus_metadata) @injection.content
  (#set! injection.language "yaml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

((plus_metadata) @injection.content
  (#set! injection.language "toml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

([
  (inline)
  (pipe_table_cell)
] @injection.content
  (#set! injection.language "markdown_inline"))
