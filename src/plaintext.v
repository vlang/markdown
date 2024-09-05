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
