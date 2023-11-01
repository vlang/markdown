/*
* MD4C: Markdown parser for C
 * (http://github.com/mity/md4c)
 *
 * Copyright (c) 2016-2019 Martin Mitáš
 * Copyright (c) 2020 Ned Palacios (V bindings)
 * Copyright (c) 2020-2021 The V Programming Language
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
*/

module markdown

fn test_render() {
	text := '# Hello World\nhello **bold**'
	out := to_html_new(text)
	assert out == '<h1>Hello World</h1><p>hello <strong>bold</strong></p>'
}

fn test_formatting() {
	assert to_html_new('*italic*') == '<p><em>italic</em></p>'
	assert to_html_new('_italic_') == '<p><em>italic</em></p>'
	assert to_html_new('**bold**') == '<p><strong>bold</strong></p>'
	assert to_html_new('__bold__') == '<p><strong>bold</strong></p>'
	assert to_html_new('***italic bold***') == '<p><em><strong>italic bold</strong></em></p>'
	assert to_html_new('___italic bold___') == '<p><em><strong>italic bold</strong></em></p>'
	assert to_html_new('~strikethrough~') == '<p><del>strikethrough</del></p>'
	assert to_html_new('~~strikethrough with two tildes~~') == '<p><del>strikethrough with two tildes</del></p>'
	assert to_html_new('~_**mixed**_~') == '<p><del><em><strong>mixed</strong></em></del></p>'
	assert to_html_new('`inline code`') == '<p><code>inline code</code></p>'

	// TODO: test cases for latexmath and wikilink
}

fn test_render_blockquote() {
	assert to_html_new('> hello world') == '<blockquote><p>hello world</p></blockquote>'
}

const item_checked = '<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" disabled checked>'

const item_unchecked = '<li class="task-list-item"><input type="checkbox" class="task-list-item-checkbox" disabled>'

fn test_render_ul() {
	assert to_html_new('
- test
- abcd
    '.trim_space()) == '<ul><li>test</li><li>abcd</li></ul>'
}

fn test_render_ul_checkbox() {
	assert to_html_new('
- [x] test
- [X] abcd
- [ ] defg
    '.trim_space()) == '<ul>${markdown.item_checked}test</li>${markdown.item_checked}abcd</li>${markdown.item_unchecked}defg</li></ul>'
}

fn test_render_ul_mixed() {
	assert to_html_new('
- [x] test
- abcd
- [ ] defg
    '.trim_space()) == '<ul>${markdown.item_checked}test</li><li>abcd</li>${markdown.item_unchecked}defg</li></ul>'
}

fn test_render_ol() {
	assert to_html_new('
1. test
2. abcd
    '.trim_space()) == '<ol><li>test</li><li>abcd</li></ol>'
}

fn test_render_ol_diff_start() {
	assert to_html_new('
4. test
7. abcd
    '.trim_space()) == '<ol start="4"><li>test</li><li>abcd</li></ol>'
}

fn test_render_ol_checkbox() {
	assert to_html_new('
1. [x] test
2. [X] abcd
3. [ ] defg
    '.trim_space()) == '<ol>${markdown.item_checked}test</li>${markdown.item_checked}abcd</li>${markdown.item_unchecked}defg</li></ol>'
}

fn test_render_ol_mixed() {
	assert to_html_new('
1. [x] test
2. abcd
3. [ ] defg
    '.trim_space()) == '<ol>${markdown.item_checked}test</li><li>abcd</li>${markdown.item_unchecked}defg</li></ol>'
}

fn test_render_ul_ol_mixed() {
	assert to_html_new('
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
		'<ol><li>Things to do<ul>${markdown.item_checked}Task 1</li>${markdown.item_unchecked}Task 2</li></ul></li>',
		'<li>Notes<ul><li>Note 1</li><li>Note 2</li></ul></li></ol>',
		'<ul><li>Hey<ol><li>Ordered 1</li><li>Ordered 2</li></ol></li></ul>',
	].join('')
}

fn test_render_hr() {
	assert to_html_new('---') == '<hr />'
	assert to_html_new('***') == '<hr />'
}

fn test_render_heading() {
	assert to_html_new('# a') == '<h1>a</h1>'
	assert to_html_new('## b') == '<h2>b</h2>'
	assert to_html_new('### c') == '<h3>c</h3>'
	assert to_html_new('#### d') == '<h4>d</h4>'
	assert to_html_new('##### e') == '<h5>e</h5>'
	assert to_html_new('###### f') == '<h6>f</h6>'
}

fn test_render_heading_error() {
	assert to_html_new('####### err') == '<p>####### err</p>'
}

fn test_render_p() {
	assert to_html_new('hello') == '<p>hello</p>'
}

fn test_render_code() {
	assert to_html_new('```\nfenced\n```') == '<pre><code>fenced\n</code></pre>'
	assert to_html_new('\tindented') == '<pre><code>indented\n</code></pre>'
}

fn test_render_code_with_lang() {
	assert to_html_new('```v\nprint("hello")\n```') == '<pre><code class="language-v">print("hello")\n</code></pre>'
}

fn test_render_table() {
	assert to_html_new('
|Column 1| Column 2 |
|--------|---|
|Item 1| Item 2 |
	'.trim_space()) == '<table><thead><tr><th>Column 1</th><th>Column 2</th></tr></thead><tbody><tr><td>Item 1</td><td>Item 2</td></tr></tbody></table>'
}

fn test_img() {
	assert to_html_new('![pic](test.png)') == '<p><img src="test.png" alt="pic" /></p>'
}

fn test_img_with_title() {
	assert to_html_new('![](test.png "img title")') == '<p><img src="test.png" alt="" title="img title" /></p>'
}

fn test_img_alt_formatting() {
	assert to_html_new('![**emphasize**](test.png)') == '<p><img src="test.png" alt="emphasize" /></p>'
}

fn test_a() {
	assert to_html_new('[this is a link](https://example.com)') == '<p><a href="https://example.com">this is a link</a></p>'
}

fn test_a_empty_text() {
	assert to_html_new('[](https://example.com)') == '<p><a href="https://example.com"></a></p>'
}

fn test_a_empty_link() {
	assert to_html_new('[link with no href]()') == '<p><a>link with no href</a></p>'
}

fn test_render_raw_html() {
	assert to_html_new('<h1>hello world</h1>') == '<h1>hello world</h1>'
}

fn test_render_entity() {
	assert to_html_new('what&apos;s up') == "<p>what's up</p>"
}

fn test_attribute_transformer() ! {
	mut renderer := HtmlRenderer{
		transformer: &AttrTransformerFn(fn (parent ParentType, name string, value string) string {
			if parent is MD_SPANTYPE && parent == .md_span_a {
				if name == 'href' && value == '.' {
					return 'https://google.com'
				}
			}
			return default_html_transformer.transform_attribute(parent, name, value)
		})
	}
	out := render('[should be google](.)', mut renderer)!
	assert out == '<p><a href="https://google.com">should be google</a></p>'
}

struct TestCodeFormatter {
mut:
	language string
}

fn (f &TestCodeFormatter) transform_attribute(parent ParentType, name string, value string) string {
	return default_html_transformer.transform_attribute(parent, name, value)
}

fn (f &TestCodeFormatter) transform_content(parent ParentType, text string) string {
	if text.trim_space().len != 0 && parent is MD_BLOCKTYPE && parent == .md_block_code {
		return '<span class="keyword">language: ${f.language} >>> ${text}</span>'
	}
	return default_html_transformer.transform_content(parent, text)
}

fn (mut f TestCodeFormatter) config_set(key string, val string) {
	if key == 'code_language' {
		f.language = val
	}
}

fn test_content_transformer() ! {
	mut renderer := HtmlRenderer{
		transformer: &TestCodeFormatter{}
	}
	out := render('```go\ntrue\n```', mut renderer)!
	assert out == '<pre><code class="language-go"><span class="keyword">language: go >>> true</span>\n</code></pre>'
}
