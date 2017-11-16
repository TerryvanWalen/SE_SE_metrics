module duplication

import IO;
import Prelude;
import String;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import codeLines;

public int codeDuplicationInProject(M3 model) {
	set[loc] projectMethods = methods(model);
	map[loc, list[str]] methodWithCodes = getCleanCodePerMethod(projectMethods);
	map[loc, list[str]] validMethodWithCodes = extractMethodsSmallerThanNumLines(methodWithCodes, 6);
	int locNonDuplicated = countNonDuplicateCodeofSize(validMethodWithCodes, 6);
	
	int locInMethods = (0 | it + 1 | l <- methodWithCodes, s <- methodWithCodes[l]);
	int locInSmallMethods = locInMethods - (0 | it + 1 | l <- validMethodWithCodes, s <- validMethodWithCodes[l]);

	int locDuplicated = locInMethods - (locNonDuplicated + locInSmallMethods);
	println("<locDuplicated>/<locInMethods> - <locDuplicated/toReal(locInMethods)>");
	return 0;
}

private map[loc, list[str]] getCleanCodePerMethod(set[loc] projectMethods) {
	map[loc, list[str]] codeLines = ();
	for (file <- projectMethods) {
		list[str] lines = extractCodeFromFiles(file);
		
		// temp solution to remove declaration of method and closing bracket
		if (size(lines) > 1) {
			lines = delete(lines, 0);
			lines = delete(lines, (size(lines) - 1));
		}
		codeLines[file] = lines;
	}
	return codeLines;
}

private map[loc, list[str]] extractMethodsSmallerThanNumLines(map[loc, list[str]] methodWithCode, int maxLines)
{
	map[loc, list[str]] codeLines = ();
	for (l <- methodWithCode) {
		list[str] code = methodWithCode[l];
		if (size(code) >= maxLines) {
			codeLines[l] = code;
		}
	}
	return codeLines;
}

private int countNonDuplicateCodeofSize(map[loc, list[str]] methodWithCode, int maxLines)
{
	int unDuplicatedLines = 0;
	list[loc] ms = ([] | it + m | m <- methodWithCode);
	for (int i <- [0..size(ms)]) {
		list[int] duplicatedCodeInCode1 = [];
		list[str] code1 = methodWithCode[ms[i]];
		for (int j <- [(i+1)..size(ms)]) {
			list[str] code2 = methodWithCode[ms[j]];
			duplicatedCodeInCode1 += getDuplicatedLinesOfSize(code1, code2, maxLines);
		}
		
		int duplicatedlines = size([0..size(code1)] - duplicatedCodeInCode1);
		println("<i>/<size(ms)>");
		unDuplicatedLines += duplicatedlines;
	}
	return unDuplicatedLines;
}

private list[int] getDuplicatedLinesOfSize(list[str] code1, list[str] code2, int maxLines)
{
	int max = maxLines - 1;
	list[int] duplicatedLines = [];
	for (int i <- [0..size(code1) - max]) {
		str line1 = code1[i];

		for (int j <- [0..size(code2) - max]) {
			str line2 = code2[j];

			if (line1 == line2) {
				int k = 0;
				while ((i+k < size(code1) && j+k < size(code2)) && code1[i+k] == code2[j+k]) { 
					k += 1;
				}
				if (k >= maxLines) {
					duplicatedLines += [i..(i+k)];
					i += k;
				}
			}
		}
	}
	return (duplicatedLines);
}