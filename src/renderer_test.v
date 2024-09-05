module markdown

fn test_render() ! {
	mut pt := PlaintextRenderer{}
	text := '# Hello World\nhello **bold**'
	out := render(text, mut pt)!
	assert out.len != 0
	assert out == 'Hello World\nhello bold'
}
