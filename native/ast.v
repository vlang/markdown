module native

struct Root {
	children []MdastContent
}

struct Literal {
	value string
}

type MdastContent = FlowContent | ListItem | PhrasingContent

struct ListItem {
	spread   bool
	children []FlowContent
}

type Content = Definition | Paragraph

struct Definition {
	identifier string
	label      string
	url        string
	title      string
}

struct Paragraph {
	children []PhrasingContent
}

type PhrasingContent = Link | LinkReference | StaticPhrasingContent

struct Link {
	children []StaticPhrasingContent
}

struct LinkReference {
	children []StaticPhrasingContent
}

type StaticPhrasingContent = Break | Emphasis | HTML | Image | ImageReference | InlineCode |
	Strong | Text

struct Break {}

struct Emphasis {
	children []Content
}

struct Strong {
	children []Content
}

struct Text {
	value string
}

struct Image {
	url   string
	title string
	alt   string
}

struct ImageReference {
	identifier     string
	label          string
	reference_type string
	alt            string
}

struct InlineCode {
	value string
}

type FlowContent = Blockquote | Code | Content | HTML | Heading | List | ThematicBreak
	

struct Blockquote {
	children []FlowContent
}

struct Code {
	lang string
	meta string
}

struct Heading {
	depth    i8 // range of 1 to 6
	children []PhrasingContent
}

struct HTML {
	value string
}

struct List {
	ordered  bool
	start    int  // it represents, when the ordered field is true, the startin number of the list
	spread   bool // if items are separated by blank lines
	children []ListItem
}

struct ThematicBreak {}
