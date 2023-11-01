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

struct PlaintextRenderer {
mut:
	writer strings.Builder = strings.new_builder(200)
}

fn (mut pt PlaintextRenderer) str() string {
	return pt.writer.str()
}

fn (mut pt PlaintextRenderer) enter_block(typ MD_BLOCKTYPE, detail voidptr) ? {
	// TODO Remove, functions can't have two args with name `_`
	_ = typ
	_ = detail
}

fn (mut pt PlaintextRenderer) leave_block(typ MD_BLOCKTYPE, _ voidptr) ? {
	if typ !in [.md_block_doc, .md_block_hr, .md_block_html] {
		pt.writer.write_u8(`\n`)
	}
}

fn (mut pt PlaintextRenderer) enter_span(typ MD_SPANTYPE, detail voidptr) ? {
	// TODO Remove, functions can't have two args with name `_`
	_ = typ
	_ = detail
}

fn (mut pt PlaintextRenderer) leave_span(typ MD_SPANTYPE, detail voidptr) ? {
	// TODO Remove, functions can't have two args with name `_`
	_ = typ
	_ = detail
}

fn (mut pt PlaintextRenderer) text(typ MD_TEXTTYPE, text string) ? {
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

fn (mut pt PlaintextRenderer) debug_log(msg string) {
	unsafe { msg.free() }
}

pub fn to_plain(input string) string {
	mut pt_renderer := PlaintextRenderer{}
	out := render(input, mut pt_renderer) or { '' }
	return out
}
