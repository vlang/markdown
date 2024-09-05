module markdown

// Renderer represents an entity that accepts incoming data and renders the content.
pub interface Renderer {
mut:
	str() string
	enter_block(typ MD_BLOCKTYPE, detail voidptr) ?
	leave_block(typ MD_BLOCKTYPE, detail voidptr) ?
	enter_span(typ MD_SPANTYPE, detail voidptr) ?
	leave_span(typ MD_SPANTYPE, detail voidptr) ?
	text(typ MD_TEXTTYPE, content string) ?
	debug_log(msg string)
}

fn renderer_handle_error(err IError) int {
	ecode := err.code()
	if ecode != 0 {
		return ecode
	} else {
		return 1
	}
}

fn renderer_enter_block_cb(typ MD_BLOCKTYPE, detail voidptr, mut renderer Renderer) int {
	renderer.enter_block(typ, detail) or { return renderer_handle_error(err) }
	return 0
}

fn renderer_leave_block_cb(typ MD_BLOCKTYPE, detail voidptr, mut renderer Renderer) int {
	renderer.leave_block(typ, detail) or { return renderer_handle_error(err) }
	return 0
}

fn renderer_enter_span_cb(typ MD_SPANTYPE, detail voidptr, mut renderer Renderer) int {
	renderer.enter_span(typ, detail) or { return renderer_handle_error(err) }
	return 0
}

fn renderer_leave_span_cb(typ MD_SPANTYPE, detail voidptr, mut renderer Renderer) int {
	renderer.leave_span(typ, detail) or { return renderer_handle_error(err) }
	return 0
}

fn renderer_text_cb(typ MD_TEXTTYPE, text &char, size u32, mut renderer Renderer) int {
	s := unsafe { text.vstring_with_len(int(size)) }
	renderer.text(typ, s) or { return renderer_handle_error(err) }
	return 0
}

fn renderer_debug_log_cb(msg &char, mut renderer Renderer) {
	renderer.debug_log(unsafe { msg.vstring() })
}

// render parses and renders a given markdown string based on the renderer.
pub fn render(src string, mut renderer Renderer) !string {
	parser := new(u32(C.MD_DIALECT_GITHUB), renderer_enter_block_cb, renderer_leave_block_cb,
		renderer_enter_span_cb, renderer_leave_span_cb, renderer_text_cb, renderer_debug_log_cb)
	err_code := parse(src.str, u32(src.len), &parser, &renderer)
	if err_code != 0 {
		return error_with_code('Something went wrong while parsing.', err_code)
	}
	res := renderer.str()
	return res.trim_space()
}
