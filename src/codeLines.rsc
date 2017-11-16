module codeLines

import IO;
import Prelude;
import String;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;


public int LOCInProject(M3 model) {
	set[loc] allProjectFiles = files(model);
	return size(extractCodeFromFiles(allProjectFiles));
}

public list[str] extractCodeFromFiles(set[loc] projectFiles) {
	list[str] rawLines = extractRawFromFiles(projectFiles);
	list[str] codeLines = extractCodeLinesAlt(rawLines);
	return codeLines;
}
public list[str] extractCodeFromFiles(loc projectFile) = extractCodeFromFiles({projectFile});

private list[str] extractRawFromFiles(set[loc] files) {
	list[str] lines = [];
	bool ok = true;
	for (f <- files) {
		if (ok == true)
			println("file is: <f>");
		ok = false;
		lines += readFileLines(f);
	}
	return lines;
}

// Problem, this solution does not recognize unproperly formatted multiline comments.
public list[str] extractCodeLinesAlt(list[str] lines) {
	//lines = removeBlockComments(lines);
	//return ([]| it + line | x <- lines, /^\s*<line:[^\/|*|\s]+.*>$/ := x);
	return cleanCode(lines);
}

public list[str] extractCodeLines(list[str] lines) {
	return ([]| it + line | x <- lines, /^\s*<line:[^\/|*|\s]+.*>$/ := x);
}

public int LOCInProject(loc project) {
	M3 model = createM3FromEclipseProject(project);
	set[loc] allProjectFiles = files(model);
	return size(extractCodeFromFiles(allProjectFiles));
}

public list[str] cleanCode(list[str] lines) {
	list[str] newLines = [];
	str newLine;
	bool block = false;
	str beforeC, afterC;
	int pos = 0;
	for (line <- lines) {
		if (contains(line, "/*") && !contains(line, "*/")) {
			block = true;
			newLine = substring(line, 0, findFirst(line, "/*"));
			newLines = addNewLine(newLines, newLine);
		}
		
		if (!block) {
			newLines = addNewLine(newLines, line);
		}
		
		if (!contains(line, "/*") && contains(line, "*/")) {
			newLine = substring(line, findFirst(line, "*/") + 2, size(line));
			newLines = addNewLine(newLines, newLine);
			block = false;
		}
		
		//if (startsWith(trim(line), "/*")) {
		//	block = true;
		//}	
		//if (!block)
		//	newLines += line;
		//
		//pos = findFirst(line, "*/");
		//if (pos != -1) {
		//	block = false;
		//	newLine = substring(line, pos + 2, size(line));
		//	println("**<line>");
		//	println("***<newLine>");
		//	newLines += newLine;
		//}	
	}
	return newLines;
}

private list[str] addNewLine(list[str] lines, str line) {
	if (!startsWith(trim(line), "//") && trim(line) != "")
		lines += line;
	return lines;

}