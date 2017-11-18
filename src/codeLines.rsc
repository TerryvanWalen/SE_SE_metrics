module codeLines

import IO;
import Prelude;
import String;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;


public int LOCInProject(M3 model) {
	set[loc] allProjectFiles = files(model);
	int count = 0;
	for (file <- allProjectFiles) {
		count += size(linesOfCode(file));
	}
	return count;
}

public list[str] linesOfCode(loc location) {
	list[str] source = readFileLines(location);
	str ss = listToStr(source);
	ss = replaceStrings(ss);
	ss = removeBlocks(ss);
	source = split("\n", ss);
	source = removeBlanks(source);
	source = removeLineComments(source);
	return source;
}

public str listToStr(list[str] lines) {
	str res = "";
	for (line <- lines) {
		res += line + "\n";
	}
	return res;
}

public list[str] addNewLines(list[str] input) {
	return ["<a>\n" | a <- input];
}

public list[str] removeBlanks(list[str] input) {
	return [a | a <- input, trim(a) != ""];
}

public str replaceStrings(str s) {
	return visit(s) {
		case /\".*\"/ => "\"S\""
	}
}

public list[str] removeLineComments(list[str] input) {
	return [a | a <- input, !startsWith(trim(a), "//")];
}

public str removeBlocks(str s) {
	return visit(s) {
		case /\/\*[\s\S]*?\*\// => ""
	}
}

public bool isOneLineComment(str s) {
	return startsWith(trim(s), "//");
}

public bool isEmptyLine(str s) {
	return trim(s) == "";
}