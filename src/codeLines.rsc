module codeLines

import IO;
import Prelude;
import String;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;


public list[str] extractCodeFromFiles(projectFiles) {
	list[str] rawLines = extractRawFromFiles(projectFiles);
	list[str] codeLines = extractCodeLines(rawLines);
	return codeLines;
}

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
private list[str] extractCodeLines(list[str] lines) {
	return ([]| it + line | x <- lines, /^\s*<line:[^\/|*|\s]+.*>$/ := x);
}

public int LOCInProject(loc project) {
	M3 model = createM3FromEclipseProject(project);
	set[loc] allProjectFiles = files(model);
	return size(extractCodeFromFiles(allProjectFiles));
}