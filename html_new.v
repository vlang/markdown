/*
* MD4C: Markdown parser for C
 * (http://github.com/mity/md4c)
 *
 * Copyright (c) 2016-2019 Martin Mitáš
 * Copyright (c) 2020/2023 Ned Palacios (V bindings / HTML Renderer)
 * Copyright (c) 2020-2023 The V Programming Language
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

import encoding.html
import strings
import datatypes { Stack }

pub type ParentType = MD_BLOCKTYPE | MD_SPANTYPE

// HtmlTransformer transforms converted HTML elements (limited 
// to attribute and content for now) from markdown before incorporated 
// into the final output. 
// 
// When implementing an HtmlTransformer, escaping the content is up 
// to you. However, it is best to wrap the values you don't need with 
// `markdown.default_html_transformer.transform_{attribute|content}`
pub interface HtmlTransformer {
	transform_attribute(parent ParentType, name string, value string) string
	transform_content(parent ParentType, text string) string
mut:
	config_set(key string, value string)
}

pub struct DefaultHtmlTransformer {}

pub fn (t &DefaultHtmlTransformer) transform_attribute(parent ParentType, name string, value string) string {
	return html.escape(value)
}

pub fn (t &DefaultHtmlTransformer) transform_content(parent ParentType, text string) string {
	return html.escape(text, quote: false)
}

pub fn (mut t DefaultHtmlTransformer) config_set(key string, val string) {}

pub const default_html_transformer = &DefaultHtmlTransformer{}

pub type AttrTransformerFn = fn (ParentType, string, string) string

pub fn (t AttrTransformerFn) transform_attribute(parent ParentType, name string, value string) string {
	val := t(parent, name, value)
	return val
}

pub fn (t AttrTransformerFn) transform_content(parent ParentType, text string) string {
	return default_html_transformer.transform_content(parent, text)
}

pub fn (mut t AttrTransformerFn) config_set(key string, val string) {}

pub type ContentTransformerFn = fn (ParentType, string) string

pub fn (t ContentTransformerFn) transform_attribute(parent ParentType, name string, value string) string {
	return default_html_transformer.transform_attribute(parent, name, value)
}

pub fn (t ContentTransformerFn) transform_content(parent ParentType, text string) string {
	return t(parent, text)
}

pub fn (mut t ContentTransformerFn) config_set(key string, val string) {}

fn tos_attribute(attr &C.MD_ATTRIBUTE, mut wr strings.Builder) {
	for i := 0; unsafe { attr.substr_offsets[i] } < attr.size; i++ {
		typ := unsafe { MD_TEXTTYPE(attr.substr_types[i]) }
		off := unsafe { attr.substr_offsets[i] }
		size := unsafe { attr.substr_offsets[i + 1] - off }
		text := unsafe { (attr.text + off).vstring_with_len(size) }

		match typ {
			.md_text_null_char {
				wr.write_string(html.unescape('&#0'))
			}
			.md_text_entity {
				if text == '&lt;' || text == '&gt;' {
					wr.write_string(text)
				} else {
					wr.write_string(html.unescape(text, all: true))
				}
			}
			else {
				wr.write_string(html.escape(text))
			}
		}
	}
}

pub struct HtmlRenderer {
pub mut:
	transformer         HtmlTransformer = markdown.default_html_transformer
mut:
	parent_stack        Stack[ParentType]
	content_writer        strings.Builder = strings.new_builder(200)
	writer              strings.Builder = strings.new_builder(200)
	image_nesting_level int
}

fn (mut ht HtmlRenderer) str() string {
	return ht.writer.str()
}

fn (mut ht HtmlRenderer) render_opening_attribute(key string, with_str_opening bool) {
	ht.writer.write_byte(` `)
	ht.writer.write_string(key)
	if with_str_opening {
		ht.writer.write_string('="')
	}
}

fn (mut ht HtmlRenderer) render_closing_attribute() {
	ht.writer.write_byte(`"`)
}

[params]
struct MdAttributeConfig {
	prefix string
	suffix string
	setting_key string
}

fn (mut ht HtmlRenderer) render_md_attribute(key string, attr &C.MD_ATTRIBUTE, cfg MdAttributeConfig) {
	if attr == 0 || attr.text == 0 {
		return
	}
	ht.content_writer.write_string(cfg.prefix)
	tos_attribute(attr, mut ht.content_writer)
	ht.content_writer.write_string(cfg.suffix)
	transformed := if parent := ht.parent_stack.peek() {
		ht.transformer.transform_attribute(parent, key, ht.content_writer.str())
	} else {
		html.escape(ht.content_writer.str())
	}
	if cfg.setting_key.len != 0 {
		tos_attribute(attr, mut ht.content_writer)
		ht.transformer.config_set(cfg.setting_key, ht.content_writer.str())
	}
	ht.render_opening_attribute(key, true)
	ht.writer.write_string(transformed)
	ht.render_closing_attribute()
}

fn (mut ht HtmlRenderer) render_attribute(key string, value string) {
	ht.render_opening_attribute(key, value.len != 0)
	if value.len != 0 {
		transformed := if parent := ht.parent_stack.peek() {
			ht.transformer.transform_attribute(parent, key, value)
		} else {
			value
		}
		
		ht.writer.write_string(transformed)
		ht.render_closing_attribute()
	}
}

fn (mut ht HtmlRenderer) render_content() {
	if ht.content_writer.len == 0 {
		return
	}

	if parent := ht.parent_stack.peek() {
		transformed := ht.transformer.transform_content(parent, ht.content_writer.str())
		ht.writer.write_string(transformed)
	} else {
		ht.writer.write_string(ht.content_writer.str())
	}
}

const html_block_tag_names = {
	MD_BLOCKTYPE.md_block_quote: 'blockquote'
	.md_block_ul:                'ul'
	.md_block_ol:                'ol'
	.md_block_li:                'li'
	.md_block_hr:                'hr'
	.md_block_h:                 'h'
	.md_block_p:                 'p'
	.md_block_code:              'pre'
	.md_block_table:             'table'
	.md_block_thead:             'thead'
	.md_block_tbody:             'tbody'
	.md_block_tr:                'tr'
	.md_block_th:                'th'
	.md_block_td:                'td'
}

const self_closing_block_types = [MD_BLOCKTYPE.md_block_hr]

fn (mut ht HtmlRenderer) enter_block(typ MD_BLOCKTYPE, detail voidptr) ? {
	ht.parent_stack.push(ParentType(typ))
	tag_name := markdown.html_block_tag_names[typ] or { return }
	ht.writer.write_byte(`<`)
	ht.writer.write_string(tag_name)
	match typ {
		.md_block_h {
			level := unsafe { &C.MD_BLOCK_H_DETAIL(detail) }.level
			ht.writer.write_string('${level}')
		}
		.md_block_ol {
			details := unsafe { &C.MD_BLOCK_OL_DETAIL(detail) }
			if details.start > 1 {
				ht.render_attribute('start', '${details.start}')
			}
		}
		.md_block_li {
			details := unsafe { &C.MD_BLOCK_LI_DETAIL(detail) }
			if details.is_task {
				ht.render_attribute('class', 'task-list-item')
			}
		}
		.md_block_th, .md_block_td {
			details := unsafe { &C.MD_BLOCK_TD_DETAIL(detail) }
			align := match details.align {
				.md_align_left { 'left' }
				.md_align_center { 'center' }
				.md_align_right { 'right' }
				else { '' }
			}
			if align.len != 0 {
				ht.render_attribute('align', align)
			}
		}
		else {}
	}
	if typ in markdown.self_closing_block_types {
		ht.writer.write_byte(` `)
		ht.writer.write_byte(`/`)
	}
	ht.writer.write_byte(`>`)

	// Extra HTML for li/code items
	if typ == .md_block_code {
		details := unsafe { &C.MD_BLOCK_CODE_DETAIL(detail) }
		ht.writer.write_string('<code')
		ht.render_md_attribute('class', details.lang, prefix: 'language-', setting_key: 'code_language')
		ht.writer.write_byte(`>`)
	} else if typ == .md_block_li {
		details := unsafe { &C.MD_BLOCK_LI_DETAIL(detail) }
		if !details.is_task {
			return
		}
		ht.writer.write_string('<input')
		ht.render_attribute('type', 'checkbox')
		ht.render_attribute('class', 'task-list-item-checkbox')
		ht.render_attribute('disabled', '')
		if details.task_mark == `x` || details.task_mark == `X` {
			ht.render_attribute('checked', '')
		}
		ht.writer.write_byte(`>`)
	}
}

fn (mut ht HtmlRenderer) leave_block(typ MD_BLOCKTYPE, detail voidptr) ? {
	ht.render_content()
	ht.parent_stack.pop() or {}
	if typ in markdown.self_closing_block_types {
		return
	}
	if typ == .md_block_code {
		ht.writer.write_string('</code>')
	}
	tag_name := markdown.html_block_tag_names[typ] or { return }
	ht.writer.write_byte(`<`)
	ht.writer.write_byte(`/`)
	ht.writer.write_string(tag_name)
	if typ == .md_block_h {
		level := unsafe { &C.MD_BLOCK_H_DETAIL(detail) }.level
		ht.writer.write_string('${level}')
	}
	ht.writer.write_byte(`>`)
}

const html_span_tag_names = {
	MD_SPANTYPE.md_span_em:     'em'
	.md_span_strong:            'strong'
	.md_span_a:                 'a'
	.md_span_img:               'img'
	.md_span_code:              'code'
	.md_span_del:               'del'
	.md_span_latexmath:         'x-equation'
	.md_span_latexmath_display: 'x-equation'
	.md_span_wikilink:          'x-wikilink'
	.md_span_u:                 'u'
}

fn (mut ht HtmlRenderer) enter_span(typ MD_SPANTYPE, detail voidptr) ? {
	if ht.image_nesting_level > 0 {
		return
	}

	ht.parent_stack.push(ParentType(typ))
	tag_name := markdown.html_span_tag_names[typ] or { return }

	ht.writer.write_byte(`<`)
	ht.writer.write_string(tag_name)

	match typ {
		.md_span_a {
			a_details := unsafe { &C.MD_SPAN_A_DETAIL(detail) }
			ht.render_md_attribute('href', a_details.href)
			ht.render_md_attribute('title', a_details.title)
		}
		.md_span_img {
			img_details := unsafe { &C.MD_SPAN_IMG_DETAIL(detail) }
			ht.render_md_attribute('src', img_details.src)
			ht.render_opening_attribute('alt', true)
			ht.image_nesting_level++
			return
		}
		.md_span_latexmath_display {
			ht.render_attribute('type', 'display')
		}
		.md_span_wikilink {
			wikilink_details := unsafe { &C.MD_SPAN_WIKILINK_DETAIL(detail) }
			ht.render_md_attribute('data-target', wikilink_details.target)
		}
		else {}
	}
	ht.writer.write_byte(`>`)
}

fn (mut ht HtmlRenderer) leave_span(typ MD_SPANTYPE, detail voidptr) ? {
	if ht.image_nesting_level > 0 {
		if ht.image_nesting_level == 1 && typ == .md_span_img {
			ht.render_closing_attribute()
			img_details := unsafe { &C.MD_SPAN_IMG_DETAIL(detail) }
			ht.render_md_attribute('title', img_details.title)
			ht.writer.write_string(' />')
			ht.image_nesting_level--
			ht.parent_stack.pop() or {}
		}
		return
	}

	ht.render_content()
	ht.parent_stack.pop() or {}
	tag_name := markdown.html_span_tag_names[typ] or { return }
	ht.writer.write_byte(`<`)
	ht.writer.write_byte(`/`)
	ht.writer.write_string(tag_name)
	ht.writer.write_byte(`>`)
}

fn (mut ht HtmlRenderer) text(typ MD_TEXTTYPE, text string) ? {
	match typ {
		.md_text_null_char {
			ht.writer.write_string('&#0')
		}
		.md_text_softbr {
			if ht.image_nesting_level > 0 {
				ht.writer.write_byte(` `)
			}
		}
		.md_text_br {
			ht.writer.write_string('<br />')
		}
		.md_text_entity {
			ht.writer.write_string(html.unescape(text, all: true))
		}
		.md_text_html {
			ht.writer.write_string(text)
		}
		else {
			if ht.image_nesting_level == 0 {
				if parent := ht.parent_stack.peek() {
					// Special code for code blocks
					if parent is MD_BLOCKTYPE && parent == .md_block_code {
						ht.content_writer.write_string(text)
						return
					}
				}
			}
			ht.writer.write_string(html.escape(text, quote: false))
		}
	}
}

fn (mut ht HtmlRenderer) debug_log(msg string) {
	unsafe { msg.free() }
}

pub fn to_html_new(input string) string {
	mut renderer := HtmlRenderer{}
	out := render(input, mut renderer) or { '' }
	return out
}
