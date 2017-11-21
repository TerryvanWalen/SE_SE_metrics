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
			int pos = findFirst(line, "*/");
			str rest = trim(substring(line, pos+2, size(line)));
			if (rest != "" && !startsWith(line, "//")) 
				code += 1;
		} else if (contains(line, "/*")) {
			cBlock = true;
			//account for code before /*
			int pos = findFirst(line, "/*");
			str rest = trim(substring(line, 0, pos));
			if (rest != "" && !startsWith(line, "//")) 
				code += 1;
		}
		else {
			if (!cBlock) {
				code += 1;
			}
		} 
	}
	return code;
}


public list[str] linesOfCode(loc location) {
	list[str] source = readFileLines(location);
	str ss = listToStr(source);
	ss = replaceStrings(ss);
	//print(ss);
	ss = removeBlocks(ss);
	source = split("\n", ss);
	source = removeBlanks(source);
	source = trimLines(source);
	//source = removeSpaces(source);
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


public list[str] removeBlanks(list[str] input) {
	return [a | a <- input, trim(a) != ""];
}

public list[str] trimLines(list[str] input) {
	return [trim(a) | a <- input];
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
		case /\"<match:.*>\"/ => "\"<replaceAll(match, "*", "X")>\""
	}
}

public str removeBlocks(str s) {
	return visit(s) {
		case /\/\*[\s\S]*?\*\// => ""
	}
}