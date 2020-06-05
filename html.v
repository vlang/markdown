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

fn C.md_html(orig_input charptr, orig_input_size u32, process_output ProcessFn, userdata voidptr, parser_flags u32, renderer_flags u32) int

const (
	need_html_esc_flag = 0x1
	need_url_esc_flag  = 0x2
	md_html_flag_debug = 0x0001
	md_html_flag_verbatim_entities = 0x0002
	md_html_flag_skip_utf8_bom = 0x0004
)

type ProcessFn = fn (t charptr, s u32, d voidptr)

fn write_data(sb &strings.Builder, txt string) {
	sb.write(txt)
}

pub fn to_html(input string) string {
	mut wr := strings.new_builder(200)

	output_fn := fn (txt charptr, s u32, d voidptr) {
		write_data(&strings.Builder(d), tos(byteptr(txt), int(s)))
	}

	C.md_html(input.str, input.len, output_fn, &wr, C.MD_DIALECT_GITHUB, 0)
	return wr.str().trim_space()
}
