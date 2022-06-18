package dectiss;

import dectiss.ParseData;

enum ParseResult {
	None;
	Some(data:ParseData);
}
