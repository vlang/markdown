/*
 * MD4C: Markdown parser for C
 * (http://github.com/mity/md4c)
 *
 * Copyright (c) 2016-2019 Martin Mitáš
 * Copyright (c) 2020 Ned Palacios (V bindings)
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

const (
	nl = '\n'
)

struct MdPlaintext {
	userdata voidptr
	process_output ProcessFn
}

fn render_output(md &MdPlaintext, text charptr, size u32) {
	md.process_output(text, size, md.userdata)
}

fn pt_enter_block_callback(typ MD_BLOCKTYPE, detail voidptr, userdata voidptr) int {
	// TODO Remove, functions can't have two args with name `_`
	_ = typ
	_ = detail
	_ = userdata
	return 0
}

fn pt_leave_block_callback(typ MD_BLOCKTYPE, _ voidptr, userdata voidptr) int {
	md := &MdPlaintext(userdata)

	if typ !in [.md_block_doc, .md_block_hr, .md_block_html] {
		render_output(md, charptr(nl.str), u32(nl.len))
	}

	return 0
}

fn pt_enter_span_callback(typ MD_SPANTYPE, detail voidptr, userdata voidptr) int {
	// TODO Remove, functions can't have two args with name `_`
	_ = typ
	_ = detail
	_ = userdata
	return 0
}

fn pt_leave_span_callback(typ MD_SPANTYPE, detail voidptr, userdata voidptr) int {
	// TODO Remove, functions can't have two args with name `_`
	_ = typ
	_ = detail
	_ = userdata
	return 0
}

fn pt_text_callback(typ MD_TEXTTYPE, text charptr, size u32, userdata voidptr) int {
	md := &MdPlaintext(userdata)
	match typ {
		.md_text_null_char {}
		.md_text_html {}
		.md_text_br,
		.md_text_softbr { render_output(md, charptr(nl.str), u32(nl.len)) }
		else { render_output(md, text, size) }
	}

	return 0
}

fn pt_debug_log_callback(msg charptr, userdata voidptr) {
	// TODO Remove, functions can't have two args with name `_`
	_ = msg
	_ = userdata
}

fn md_text(orig_input charptr, input_size u32, process_output ProcessFn, userdata voidptr, parser_flags u32) int {
	parser := new(
		parser_flags,
		pt_enter_block_callback,
		pt_leave_block_callback,
		pt_enter_span_callback,
		pt_leave_span_callback,
		pt_text_callback,
		pt_debug_log_callback
	)
	mut pt := MdPlaintext{
		userdata: userdata,
		process_output: process_output
	}
	mut input := unsafe { tos3(orig_input) }
	return parse(charptr(input.str), input_size, &parser, &pt)
}


pub fn to_plain(input string) string {
	mut wr := strings.new_builder(200)
	md_text(charptr(input.str), u32(input.len), write_data_cb, &wr, u32(C.MD_DIALECT_GITHUB))
	return wr.str().trim_space()
}
