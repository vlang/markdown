module markdown

import strings

fn C.md_html(orig_input &char, orig_input_size u32, process_output ProcessFn, userdata voidptr, parser_flags u32, renderer_flags u32) int

const need_html_esc_flag = 0x1
const need_url_esc_flag = 0x2
const md_html_flag_debug = 0x0001
const md_html_flag_verbatim_entities = 0x0002
const md_html_flag_skip_utf8_bom = 0x0004

type ProcessFn = fn (t &char, s u32, x voidptr)

fn write_data_cb(txt &char, size u32, mut sb strings.Builder) {
	s := unsafe { tos(&u8(txt), int(size)) }
	sb.write_string(s)
}

pub fn to_html(input string) string {
	mut wr := strings.new_builder(200)
	C.md_html(voidptr(input.str), input.len, write_data_cb, &wr, C.MD_DIALECT_GITHUB, 0)
	return wr.str().trim_space()
}
