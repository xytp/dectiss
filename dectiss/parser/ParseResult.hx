package dectiss.parser;

enum ParseResult<A> {
	NoMatch;
	ThrowMatch;
	EmptyMatch;
	TextMatch(content:String);
	AstMatch(value:A);
}
