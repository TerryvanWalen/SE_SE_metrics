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

//public list[str] extractCodeFromFiles(set[loc] projectFiles) {
//	list[str] rawLines = extractRawFromFiles(projectFiles);
//	list[str] codeLines = extractCodeLinesAlt(rawLines);
//	return codeLines;
//}
//
//public list[str] extractCodeFromFiles(loc projectFile) = extractCodeFromFiles({projectFile});
//
//private list[str] extractRawFromFiles(set[loc] files) {
//	list[str] lines = [];
//	bool ok = true;
//	for (f <- files) {
//		if (ok == true)
//			println("file is: <f>");
//		ok = false;
//		lines += readFileLines(f);
//	}
//	return lines;
//}
//
//// Problem, this solution does not recognize unproperly formatted multiline comments.
//public list[str] extractCodeLinesAlt(list[str] lines) {
//	//lines = removeBlockComments(lines);
//	//return ([]| it + line | x <- lines, /^\s*<line:[^\/|*|\s]+.*>$/ := x);
//	return cleanCode(lines);
//}
//
//public list[str] extractCodeLines(list[str] lines) {
//	return ([]| it + line | x <- lines, /^\s*<line:[^\/|*|\s]+.*>$/ := x);
//}
//
//public int LOCInProject(loc project) {
//	M3 model = createM3FromEclipseProject(project);
//	set[loc] allProjectFiles = files(model);
//	return size(extractCodeFromFiles(allProjectFiles));
//}
//
//public str rr(str line) {
//	int p, q;
//	//p = findFirst(line, "/*");
//	//println("p is <p>");
//	//println("searching for q in: <substring(line, p + 2, size(line))>");
//	//q = findFirst(substring(line, p + 2, size(line)), "*/");
//	//println("found at <q> but the real is at <q + p>");
//	//if (p > -1 && q > -1) {
//	//	println("from 0 to <p> and from <q+p+4> to <size(line)>");
//	//	line = substring(line, 0, p) + substring(line, q + p + 4, size(line));
//	//}
//	//
//	//println("***************");
//	//p = findFirst(line, "/*");
//	//println("p is <p>");
//	//println("searching for q in: <substring(line, p + 2, size(line))>");
//	//q = findFirst(substring(line, p + 2, size(line)), "*/");
//	//println("found at <q> but the real is at <q + p>");
//	//if (p > -1 && q > -1) {
//	//	println("from 0 to <p> and from <q+p+4> to <size(line)>");
//	//	line = substring(line, 0, p) + substring(line, q + p + 4, size(line));
//	//}
//	
//	p = findFirst(line, "/*");
//	//println("p is <p>");
//	//println("searching for q in: <substring(line, p + 2, size(line))>");
//	q = findFirst(substring(line, p + 2, size(line)), "*/");
//	//println("found at <q> but the real is at <q + p>");
//	while (p > -1 && q > -1) {
//		//println("from 0 to <p> and from <q+p+4> to <size(line)>");
//		line = substring(line, 0, p) + substring(line, q + p + 4, size(line));
//		if (size(line) > 4) {
//			p = findFirst(line, "/*");
//			//println("p is <p>");
//			//println("searching for q in: <substring(line, p + 2, size(line))>");
//			q = findFirst(substring(line, p + 2, size(line)), "*/");
//			//println("found at <q> but the real is at <q + p>");	
//		}
//		else {	
//			p = -1;
//			q = -1;
//		} 
//		
//	}
//	
//	//while (p > -1 && q > -1) {
//	//	line = substring(line, 0, p) + substring(line, q + 2, size(line));
//	//	println("p is <p> and q is <q>");
//	//	p = findFirst(line, "/*");
//	//	q = findFirst(substring(line, p + 2, size(line)), "*/");
//	//}
//	return line;
//}
//
//public int linesOfCode(M3 model) {
//	set[loc] allProjectFiles = files(model);
//	int total = 0;
//	for (file <- allProjectFiles) {
//		total += countCode(readFileLines(file));
//	}
//	return total;
//}
//
//public void hahah() {
//	println(cleanCode(readFileLines(|java+compilationUnit:///src/smallsql/junit/TestStatement.java|)));
//}
//
//public int countCode(list[str] file) {
//	int count = 0;
//	int comm = 0;	
//	int blank = 0;
//	bool commentBlock = false;
//	for (line <- file) {
//		if (trim(line) == "") {
//			blank += 1;
//		} else if (startsWith(trim(line),"/*")) {
//			if (!endsWith(trim(line),"*/")) {
//				commentBlock = true;
//			}
//			comm += 1;
//		} else if (startsWith(trim(line),"*/") || endsWith(trim(line),"*/")) {
//			commentBlock = false;
//			comm += 1;
//		} else if (commentBlock || startsWith(trim(line),"/") || startsWith(trim(line),"*")) {
//			comm += 1;
//		} else {
//			if (endsWith(trim(line),"/*")) {
//				commentBlock = true;
//			}
//			count += 1;
//		}
//	}
//	return count;
//}
//
////Cleans the source code by deleting 
//public list[str] cleanCode(list[str] lines) {
//	list[str] newLines = [];
//	str newLine;
//	bool block = false;
//	str beforeC, afterC;
//	int pos = 0;
//	for (line <- lines) {
//		if (contains(line, "/*") && !contains(line, "*/")) {
//			block = true;
//			newLine = substring(line, 0, findFirst(line, "/*"));
//			newLines = addNewLine(newLines, newLine);
//		}
//		
//		if (!block) {
//			newLines = addNewLine(newLines, line);
//		}
//		
//		if (!contains(line, "/*") && contains(line, "*/")) {
//			newLine = substring(line, findFirst(line, "*/") + 2, size(line));
//			newLines = addNewLine(newLines, newLine);
//			block = false;
//		}
//	}
//	return newLines;
//}
//
//public list[str] addNewLine(list[str] lines, str line) {
//	//if (size(line) >= 4) {
//	//	line = trim(rr(line));
//	//}
//	
//	if (!startsWith(trim(line), "//") && trim(line) != "") {
//		//println(line);
//		lines += line;
//	}
//	
//	return lines;
//
//}