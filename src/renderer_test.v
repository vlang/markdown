module markdown

fn test_render() ! {
	mut pt := PlaintextRenderer{}
	text := '# Hello World\nhello **bold**'
	out := render(text, mut pt)!
	assert out.len != 0
	assert out == 'Hello World\nhello bold'
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
	mut xx := HtmlRenderer{}
	out := render(markdown.code_block, mut xx)!
	dump(out)
	assert out.starts_with('<p>start</p><pre><code>├── static/')
	assert out.ends_with('└── main.v\n</code></pre><p>end</p>')
}
