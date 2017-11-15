module codeLines

import IO;
import Prelude;
import String;


public list[str] extractCodeFromFiles(set[loc] projectFiles) {
	list[str] rawLines = extractRawFromFiles(projectFiles);
	list[str] codeLines = extractCodeLines(rawLines);
	return codeLines;
}

private list[str] extractRawFromFiles(set[loc] files) {
	list[str] lines = [];
	for (f <- files) {
		lines += readFileLines(f);
	}
	return lines;
}

// Problem, this solution does not recognize unproperly formatted multiline comments.
private list[str] extractCodeLines(list[str] lines) {
	return ([]| it + line | x <- lines, /^\s*<line:[^\/|*|\s]+.*>$/ := x);
}