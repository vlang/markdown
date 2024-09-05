import markdown

fn test_to_plain() ! {
	assert markdown.to_plain('# Hello World\nhello **bold**') == 'Hello World\nhello bold'
}

const code_block = 'start
```
├── static/
│   ├── css/
│   │   └── main.css
│   └── js/
│       └── main.js
└── main.v
```
end'

fn test_render_code_block_as_html() {
	mut xx := markdown.HtmlRenderer{}
	out := markdown.render(code_block, mut xx)!
	assert out.starts_with('<p>start</p><pre><code>├── static/')
	assert out.ends_with('└── main.v\n</code></pre><p>end</p>')
}

fn test_render_code_block_as_highlighted_html() {
	mut highlighter := &MdHtmlCodeHighlighter{}
	mut xx := markdown.HtmlRenderer{
		transformer: highlighter
	}
	out := markdown.render(code_block, mut xx)!
	assert highlighter.ok == 1
	assert out.starts_with('<p>start</p><pre><code>├── static/')
	assert out.ends_with('└── main.v\n</code></pre><p>end</p>')
}

struct MdHtmlCodeHighlighter {
pub mut:
	language string
	ok       int
}

fn (f &MdHtmlCodeHighlighter) transform_attribute(p markdown.ParentType, name string, value string) string {
	return markdown.default_html_transformer.transform_attribute(p, name, value)
}

fn (f &MdHtmlCodeHighlighter) transform_content(parent markdown.ParentType, text string) string {
	if parent is markdown.MD_BLOCKTYPE && parent == .md_block_code {
		unsafe { f.ok++ }
		return text
	}
	return text
}

fn (mut f MdHtmlCodeHighlighter) config_set(key string, val string) {
	if key == 'code_language' {
		f.language = val
	}
}
