module markdown

fn test_to_html() {
	text := '# Hello World!'
	result := to_html(text)
	assert result == '<h1>Hello World!</h1>'
}

fn test_to_plain() {
	text := '# Hello World\nhello **bold**'
	out := to_plain(text)
	assert out == 'Hello World\nhello bold'
}
