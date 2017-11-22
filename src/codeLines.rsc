module codeLines

import IO;
import Prelude;
import String;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

public int locInCodeBase(map[loc, list[str]] codeBase) {
	return (0 | it + size(codeBase[l]) | l <- codeBase);
}

public map[loc, list[str]] getCleanCodePerFile(set[loc] projectMethods) {
	return (file: linesOfCodeC(file) | file <- projectMethods);
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
	//println(listToStr(cleanLines));
	return cleanLines;
}

/**
* Returns the grade according to the number of lines of code
*/
public str getGradeLOC(int linesOfCode) {
	linesOfCode = linesOfCode / 1000;
	if (linesOfCode <= 66) 
		return "++";
	if (linesOfCode <= 246)
		return "+";
	if (linesOfCode <= 665)
		return "o";
	if (linesOfCode <= 1310)
		return "-";
	return "--";
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

public str replaceStringsAndTrim(str input) {
	return trim(replaceStrings(input));
}

public list[str] removeBlanks(list[str] input) {
	return [a | a <- input, trim(a) != ""];
}


public list[str] removeLineComments(list[str] input) {
	return [a | a <- input, !startsWith(trim(a), "//")];
}

public str replaceStrings(str s) {
	return visit(s) {
		case /\"<match:.*>\"/ => "\"<replaceAll(match, "*", "[*]")>\""
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