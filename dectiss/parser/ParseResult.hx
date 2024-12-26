package dectiss.parser;

enum ParseResult<A> {
	NoMatch;
	ThrowMatch;
	EmptyMatch;
	AstMatch(value:A);
}
