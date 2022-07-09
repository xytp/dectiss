package dectiss.parser;

import dectiss.lexer.LexResult;

typedef Rule<A> = (Array<LexResult>, Int) -> {capture: ParseResult<A>, size: Int}
