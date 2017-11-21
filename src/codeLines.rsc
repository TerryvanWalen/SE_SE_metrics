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
	int fileCount = 0;
	for (file <- allProjectFiles) {
		count += size(linesOfCodeC(file));
		fileCount += 1;
	}
	println("<fileCount> files in the project");
	return count;
}

public list[str] linesOfCodeC(loc location) {
	list[str] source = readFileLines(location);
	int blanks = 0;
	int code = 0;
	int comments = 0;
	str originalLine;
	bool cBlock = false;
	list [str] cleanLines = [];
	
	for (line <- source) {
		originalLine = line;
		line = replaceStringsAndTrim(line);
		if (contains(line, "/*") && contains(line, "*/") && !cBlock) {
			line = trim(removeBlocks(line));
			originalLine = line;
		}
			
		if (line == "") { //blanks
			blanks += 1;
		} else if (startsWith(line, "//") && !cBlock) { //line comments
			comments += 1;
		} else if (startsWith(line, "/*")) { //start of clean blocks
			cBlock = true;
			comments += 1;
		} else if (endsWith(line, "*/") && cBlock) { //end of clean blocks
			cBlock = false;
			comments += 1;
		} else if (contains(line, "*/")) {//end with just contains
			cBlock = false;
			//account for code after */
			int pos = findFirst(line, "*/");
			str rest = trim(substring(line, pos+2, size(line)));
			if (rest != "" && !startsWith(line, "//")) {
				cleanLines += cleanLine(originalLine);
				code += 1;
			} 
			
			if (contains(rest, "/*"))
				cBlock = true;	
		} else if (contains(line, "/*")) {
			//account for code before /*
			int pos = findFirst(line, "/*");
			str rest = trim(substring(line, 0, pos));
			if (rest != "" && !startsWith(line, "//") && !cBlock) {
				code += 1;
				cleanLines += cleanLine(originalLine);
			}
			cBlock = true; 
		}
		else {
			if (!cBlock) {
				code += 1;
				cleanLines += cleanLine(originalLine);
			}
		} 
	}
	println(listToStr(cleanLines));
	return cleanLines;
}

public str cleanLine(str line) {
	int pos = findFirst(line, "//");
	if (pos > -1)
		line = substring(line, 0, pos);
	pos = findFirst(line, "/*");
	if (pos > -1)
		line = substring(line, 0, pos);
	pos = findFirst(line, "*/");
	if (pos > -1)
		line = substring(line, pos + 2, size(line));
	return trim(line);
}

public str listToStr(list[str] lines) {
	str res = "";
	for (line <- lines) {
		res += line + "\n";
	}
	return res;
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

public str replaceStringsAndTrim(str input) {
	return trim(replaceStrings(input));
}

public list[str] removeBlanks(list[str] input) {
	return [a | a <- input, trim(a) != ""];
}

public list[str] removeSpaces(list[str] input) {
	return visit(input) {
		case /\s/ => ""
	}
}

public list[str] removeLineComments(list[str] input) {
	return [a | a <- input, !startsWith(trim(a), "//")];
}

public str replaceStrings(str s) {
	return visit(s) {
		case /\".*\"/ => "\"*\""
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