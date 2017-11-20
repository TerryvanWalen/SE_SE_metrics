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
		//count += size(linesOfCode(file));
		count += linesOfCodeC(file);
		//break;
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
	source = removeSpaces(source);
	source = removeLineComments(source);
	return source;
}

public int linesOfCodeC(loc location) {
	list[str] source = readFileLines(location);
	int blanks = 0;
	int code = 0;
	int comments = 0;
	bool cBlock = false;
	source = replaceStringsAndTrim(source);
	
	for (line <- source) {
		if (contains(line, "/*") && contains(line, "*/"))
			line = trim(removeBlocks(line));
			
		if (line == "") { //blanks
			blanks += 1;
		} else if (startsWith(line, "//")) { //line comments
			comments += 1;
		} else if (startsWith(line, "/*")) { //start of clean blocks
			cBlock = true;
			comments += 1;
		} else if (endsWith(line, "*/")) { //end of clean blocks
			cBlock = false;
			comments += 1;
		} else if (contains(line, "*/")) {
			cBlock = false;
			//account for code after */
		} else if (contains(line, "/*")) {
			cBlock = true;
			//account for code before /*
		}
		else {
			if (!cBlock) {
				code += 1;
			}
			
		} 
	}
	return code;
}

public str listToStr(list[str] lines) {
	str res = "";
	for (line <- lines) {
		res += line + "\n";
	}
	return res;
}

public list[str] replaceStringsAndTrim(list[str] input) {
	return [trim(replaceStrings(a)) | a <- input];
}

public list[str] removeBlanks(list[str] input) {
	return [a | a <- input, a != ""];
}


public list[str] removeSpaces(list[str] input) {
	return visit(input) {
		case /\s/ => ""
	}
}

public list[str] removeLineComments(list[str] input) {
	return [a | a <- input, !startsWith(a, "//")];
}

public str replaceStrings(str s) {
	return visit(s) {
		case /\".*\"/ => "\"\""
	}
}


public list[str] removeLineComments(list[str] input) {
	return [a | a <- input, !startsWith(a, "//")];
}

public str removeBlocks(str s) {
	return visit(s) {
		case /\/\*[\s\S]*?\*\// => ""
	}
}