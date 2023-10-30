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

import strings

pub struct HtmlRenderer {
mut:
	writer strings.Builder = strings.new_builder(200)
}

fn (mut pt HtmlRenderer) enter_block(typ MD_BLOCKTYPE, detail voidptr) ? {
	de

	match typ {
		.md_block_doc {}
		.md_block_quote {
			pt.writer.write_string("<blockquote>")
		}
		.md_block_ul {
			pt.writer.write_string("<ul>")
		}
		.md_block_ol {
			pt.writer.write_string("<ol>")
		}
		.md_block_li {
			pt.writer.write_string("<li>")
		}
		.md_block_hr {
			pt.writer.write_string("<hr />")
		}
		.md_block_h {
			pt.writer.write_string
		}
		.md_block_code {}
		.md_block_html {}
		.md_block_p {}
		.md_block_table {}
		.md_block_thead {}
		.md_block_tbody {}
		.md_block_tr {}
		.md_block_th {}
		.md_block_td {}
	}
}

fn (mut pt HtmlRenderer) leave_block(typ MD_BLOCKTYPE, _ voidptr) ? {
	match typ {
		.md_block_doc {}
		.md_block_quote {}
		.md_block_ul {}
		.md_block_ol {}
		.md_block_li {}
		.md_block_hr {}
		.md_block_h {}
		.md_block_code {}
		.md_block_html {}
		.md_block_p {}
		.md_block_table {}
		.md_block_thead {}
		.md_block_tbody {}
		.md_block_tr {}
		.md_block_th {}
		.md_block_td {}
	}
}

fn (mut pt HtmlRenderer) enter_span(typ MD_SPANTYPE, detail voidptr) ? {
	// TODO Remove, functions can't have two args with name `_`
	_ = typ
	_ = detail
}

fn (mut pt HtmlRenderer) leave_span(typ MD_SPANTYPE, detail voidptr) ? {
	// TODO Remove, functions can't have two args with name `_`
	_ = typ
	_ = detail
}

fn (mut pt HtmlRenderer) text(typ MD_TEXTTYPE, text string) ? {
	match typ {
		.md_text_null_char {}
		.md_text_html {}
		.md_text_br, .md_text_softbr {
			pt.writer.write_u8(`\n`)
		}
		else {
			pt.writer.write_string(text)
		}
	}
}

fn (mut pt HtmlRenderer) debug_log(msg string) {
	unsafe { msg.free() }
}

pub fn to_html_new(input string) string {
	mut pt_renderer := PlaintextRenderer{}
	render(input, mut pt_renderer) or { return '' }
	return pt_renderer.writer.str().trim_space()
}
