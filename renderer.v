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

// Renderer represents an entity that accepts incoming data and renders the content.
pub interface Renderer {
mut:
	enter_block(typ MD_BLOCKTYPE, detail voidptr) ?
	leave_block(typ MD_BLOCKTYPE, detail voidptr) ?
	enter_span(typ MD_SPANTYPE, detail voidptr) ?
	leave_span(typ MD_SPANTYPE, detail voidptr) ?
	text(typ MD_TEXTTYPE, content string) ?
	debug_log(msg string)
}

fn renderer_handle_error(err IError) int {
	if err.code != 0 {
		return err.code
	} else {
		return 1
	}
}

fn renderer_enter_block_cb(typ MD_BLOCKTYPE, detail voidptr, mut renderer Renderer) int {
	renderer.enter_block(typ, detail) or {
		return renderer_handle_error(err)
	}
	return 0
}

fn renderer_leave_block_cb(typ MD_BLOCKTYPE, detail voidptr, mut renderer Renderer) int {
	renderer.leave_block(typ, detail) or {
		return renderer_handle_error(err)
	}
	return 0
}

fn renderer_enter_span_cb(typ MD_SPANTYPE, detail voidptr, mut renderer Renderer) int {
	renderer.enter_span(typ, detail) or {
		return renderer_handle_error(err)
	}
	return 0
}

fn renderer_leave_span_cb(typ MD_SPANTYPE, detail voidptr, mut renderer Renderer) int {
	renderer.leave_span(typ, detail) or {
		return renderer_handle_error(err)
	}
	return 0
}

fn renderer_text_cb(typ MD_TEXTTYPE, text &char, size u32, mut renderer Renderer) int {
	renderer.text(typ, unsafe { text.vstring_with_len(int(size)) }) or {
		return renderer_handle_error(err)
	}
	return 0
}

fn renderer_debug_log_cb(msg &char, mut renderer Renderer) {
	renderer.debug_log(unsafe { msg.vstring() })
}

// render parses and renders a given markdown string based on the renderer. 
pub fn render(src string, mut renderer Renderer) ? {
	parser := new(u32(C.MD_DIALECT_GITHUB), renderer_enter_block_cb, renderer_leave_block_cb,
		renderer_enter_span_cb, renderer_leave_span_cb, renderer_text_cb, renderer_debug_log_cb)

	err_code := parse(src.str, u32(src.len), &parser, &renderer)
	if err_code != 0 {
		return error_with_code('Something went wrong while parsing.', err_code)
	}
}
