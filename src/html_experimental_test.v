import markdown

fn test_render() {
	text := '# Hello World\nhello **bold**'
	out := markdown.to_html_experimental(text)
	assert out == '<h1>Hello World</h1><p>hello <strong>bold</strong></p>'
}

fn test_formatting() {
	assert markdown.to_html_experimental('*italic*') == '<p><em>italic</em></p>'
	assert markdown.to_html_experimental('_italic_') == '<p><em>italic</em></p>'
	assert markdown.to_html_experimental('**bold**') == '<p><strong>bold</strong></p>'
	assert markdown.to_html_experimental('__bold__') == '<p><strong>bold</strong></p>'
	assert markdown.to_html_experimental('***italic bold***') == '<p><em><strong>italic bold</strong></em></p>'
	assert markdown.to_html_experimental('___italic bold___') == '<p><em><strong>italic bold</strong></em></p>'
	assert markdown.to_html_experimental('~strikethrough~') == '<p><del>strikethrough</del></p>'
	assert markdown.to_html_experimental('~~strikethrough with two tildes~~') == '<p><del>strikethrough with two tildes</del></p>'
	assert markdown.to_html_experimental('~_**mixed**_~') == '<p><del><em><strong>mixed</strong></em></del></p>'
	assert markdown.to_html_experimental('`inline code`') == '<p><code>inline code</code></p>'

	// TODO: test cases for latexmath and wikilink
}

fn test_render_blockquote() {
	assert markdown.to_html_experimental('> hello world') == '<blockquote><p>hello world</p></blockquote>'
}

const item_checked = '<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" disabled checked>'

const item_unchecked = '<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" disabled>'

fn test_render_ul() {
	assert markdown.to_html_experimental('
- test
- abcd
    '.trim_space()) == '<ul><li>test</li><li>abcd</li></ul>'
}

fn test_render_ul_checkbox() {
	assert markdown.to_html_experimental('
- [x] test
- [X] abcd
- [ ] defg
    '.trim_space()) == '<ul>${item_checked}test</li>${item_checked}abcd</li>${item_unchecked}defg</li></ul>'
}

fn test_render_ul_mixed() {
	assert markdown.to_html_experimental('
- [x] test
- abcd
- [ ] defg
    '.trim_space()) == '<ul>${item_checked}test</li><li>abcd</li>${item_unchecked}defg</li></ul>'
}

fn test_render_ol() {
	assert markdown.to_html_experimental('
1. test
2. abcd
    '.trim_space()) == '<ol><li>test</li><li>abcd</li></ol>'
}

fn test_render_ol_diff_start() {
	assert markdown.to_html_experimental('
4. test
7. abcd
    '.trim_space()) == '<ol start="4"><li>test</li><li>abcd</li></ol>'
}

fn test_render_ol_checkbox() {
	assert markdown.to_html_experimental('
1. [x] test
2. [X] abcd
3. [ ] defg
    '.trim_space()) == '<ol>${item_checked}test</li>${item_checked}abcd</li>${item_unchecked}defg</li></ol>'
}

fn test_render_ol_mixed() {
	assert markdown.to_html_experimental('
1. [x] test
2. abcd
3. [ ] defg
    '.trim_space()) == '<ol>${item_checked}test</li><li>abcd</li>${item_unchecked}defg</li></ol>'
}

fn test_render_ul_ol_mixed() {
	assert markdown.to_html_experimental('
1. Things to do
   - [x] Task 1
   - [ ] Task 2
2. Notes
   - Note 1
   - Note 2

- Hey
   1. Ordered 1
   2. Ordered 2
    '.trim_space()) == [
		'<ol><li>Things to do<ul>${item_checked}Task 1</li>${item_unchecked}Task 2</li></ul></li>',
		'<li>Notes<ul><li>Note 1</li><li>Note 2</li></ul></li></ol>',
		'<ul><li>Hey<ol><li>Ordered 1</li><li>Ordered 2</li></ol></li></ul>',
	].join('')
}

fn test_render_hr() {
	assert markdown.to_html_experimental('---') == '<hr />'
	assert markdown.to_html_experimental('***') == '<hr />'
}

fn test_render_heading() {
	assert markdown.to_html_experimental('# a') == '<h1>a</h1>'
	assert markdown.to_html_experimental('## b') == '<h2>b</h2>'
	assert markdown.to_html_experimental('### c') == '<h3>c</h3>'
	assert markdown.to_html_experimental('#### d') == '<h4>d</h4>'
	assert markdown.to_html_experimental('##### e') == '<h5>e</h5>'
	assert markdown.to_html_experimental('###### f') == '<h6>f</h6>'
}

fn test_render_heading_error() {
	assert markdown.to_html_experimental('####### err') == '<p>####### err</p>'
}

fn test_render_p() {
	assert markdown.to_html_experimental('hello') == '<p>hello</p>'
}

fn test_render_code() {
	assert markdown.to_html_experimental('```\nfenced\n```') == '<pre><code>fenced\n</code></pre>'
	assert markdown.to_html_experimental('\tindented') == '<pre><code>indented\n</code></pre>'
}

fn test_render_code_with_lang() {
	assert markdown.to_html_experimental('```v\nprint("hello")\n```') == '<pre><code class="language-v">print("hello")\n</code></pre>'
}

fn test_render_table() {
	assert markdown.to_html_experimental('
|Column 1| Column 2 |
|--------|---|
|Item 1| Item 2 |
	'.trim_space()) == '<table><thead><tr><th>Column 1</th><th>Column 2</th></tr></thead><tbody><tr><td>Item 1</td><td>Item 2</td></tr></tbody></table>'
}

fn test_img() {
	assert markdown.to_html_experimental('![pic](test.png)') == '<p><img src="test.png" alt="pic" /></p>'
}

fn test_img_with_title() {
	assert markdown.to_html_experimental('![](test.png "img title")') == '<p><img src="test.png" alt="" title="img title" /></p>'
}

fn test_img_alt_formatting() {
	assert markdown.to_html_experimental('![**emphasize**](test.png)') == '<p><img src="test.png" alt="emphasize" /></p>'
}

fn test_a() {
	assert markdown.to_html_experimental('[this is a link](https://example.com)') == '<p><a href="https://example.com">this is a link</a></p>'
}

fn test_a_empty_text() {
	assert markdown.to_html_experimental('[](https://example.com)') == '<p><a href="https://example.com"></a></p>'
}

fn test_a_empty_link() {
	assert markdown.to_html_experimental('[link with no href]()') == '<p><a>link with no href</a></p>'
}

fn test_render_raw_html() {
	assert markdown.to_html_experimental('<h1>hello world</h1>') == '<h1>hello world</h1>'
}

fn test_render_raw_html_inside_code_inline() {
	assert markdown.to_html_experimental('`<h1>Hello world!</h1>`') == '<p><code>&lt;h1&gt;Hello world!&lt;/h1&gt;</code></p>'
}

fn test_render_raw_html_alongside_code_inline() {
	assert markdown.to_html_experimental('`<h1>Hello world!</h1>`<h1>Hello world!</h1>') == '<p><code>&lt;h1&gt;Hello world!&lt;/h1&gt;</code><h1>Hello world!</h1></p>'
}

fn test_render_raw_html_inside_code_block() {
	assert markdown.to_html_experimental('```v\nhtml.parse(\'<h1 class="title">Hello world!</h1>\')\n```') == '<pre><code class="language-v">html.parse(\'&lt;h1 class="title"&gt;Hello world!&lt;/h1&gt;\')\n</code></pre>'
}

fn test_render_raw_html_alongside_code_block() {
	assert markdown.to_html_experimental('```v\nhtml.parse(\'<h1 class="title">Hello world!</h1>\')\n```\n<h1 class="title">Hello world!</h1>') == '<pre><code class="language-v">html.parse(\'&lt;h1 class="title"&gt;Hello world!&lt;/h1&gt;\')\n</code></pre><h1 class="title">Hello world!</h1>'
}

fn test_render_entity() {
	assert markdown.to_html_experimental('what&apos;s up') == "<p>what's up</p>"
}

fn replace_href_with_google_link(parent markdown.ParentType, name string, value string) string {
	if parent is markdown.MD_SPANTYPE && parent == .md_span_a {
		if name == 'href' && value == '.' {
			return 'https://google.com'
		}
	}
	return markdown.default_html_transformer.transform_attribute(parent, name, value)
}

fn test_attribute_transformer() ! {
	mut renderer := markdown.HtmlRenderer{
		transformer: &markdown.AttrTransformerFn(replace_href_with_google_link)
	}
	out := markdown.render('[should be google](.)', mut renderer)!
	assert out == '<p><a href="https://google.com">should be google</a></p>'
}

struct TestCodeFormatter {
mut:
	language string
}

fn (f &TestCodeFormatter) transform_attribute(parent markdown.ParentType, name string, value string) string {
	return markdown.default_html_transformer.transform_attribute(parent, name, value)
}

fn (f &TestCodeFormatter) transform_content(parent markdown.ParentType, text string) string {
	if text.trim_space().len != 0 && parent is markdown.MD_BLOCKTYPE && parent == .md_block_code {
		return '<span class="keyword">language: ${f.language} >>> ${text}</span>'
	}
	return markdown.default_html_transformer.transform_content(parent, text)
}

fn (mut f TestCodeFormatter) config_set(key string, val string) {
	if key == 'code_language' {
		f.language = val
	}
}

fn test_content_transformer() ! {
	mut renderer := markdown.HtmlRenderer{
		transformer: &TestCodeFormatter{}
	}
	out := markdown.render('```go\ntrue\n```', mut renderer)!
	assert out == '<pre><code class="language-go"><span class="keyword">language: go >>> true\n</span></code></pre>'
}
