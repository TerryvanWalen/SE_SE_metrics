module duplicationFast

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
	//map[loc, list[str]] orderedMethodWithCodes = getCleanCodePerMethodOrdered(methodWithCodes);
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
		// maybe remove all whitespace
		codeLines[file] = lines;
	}
	return codeLines;
}

//private map[loc, list[str]] getCleanCodePerMethodOrdered(map[loc, list[str]] projectMethods) {
//	map[loc, list[str]] codeLines = ();
//	for (l <- methodWithCode) {
//		list[str] code = methodWithCode[l];
//}

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
		list[int] code1SizeList = [0..size(code1)];
		for (int j <- [(i+1)..size(ms)]) {
			list[str] code2 = methodWithCode[ms[j]];
			duplicatedCodeInCode1 += getDuplicatedLinesOfSize(code1, code2, maxLines, false);
		}
		
		duplicatedCodeInCode1 += getDuplicatedLinesOfSize(code1, code1, maxLines, true);
		
		println("<i>/<size(ms)> - <size(code1) - (size([0..size(code1)] - duplicatedCodeInCode1))>/<size(code1)>");
		unDuplicatedLines += size([0..size(code1)] - duplicatedCodeInCode1);
	}
	return unDuplicatedLines;
}

private list[int] getDuplicatedLinesOfSize(list[str] code1, list[str] code2, int maxLines, bool sameFile)
{
	int max = maxLines - 1;
	list[int] duplicatedLines = [];
	str line1 = "";
	str line2 = "";
	//println(([maxLines-1] | it + l | l <- [maxLines+1 .. size(code1)], (l+1) % maxLines == 0));
	
	//for (int i <- ([maxLines-1] | it + l | l <- [maxLines+1 .. size(code1)], (l+1) % maxLines == 0)) {}
	
	int mRem = 0;
	int i = max;
	while (i < size(code1)) {		
		line1 = code1[i];
		
		int j = sameFile ? i+1 : 0;
		while (j < size(code2) - 1) {
			line2 = code2[j];

			if (line1 == line2) {
				int k = 0;
				while (k + 1 < maxLines && j-k-1 >= 0 && code1[i-k-1] == code2[j-k-1]) { 
					k += 1;
				}
				int m = 0;
				while ((i+m+1 < size(code1) && j+m+1 < size(code2)) && code1[i+m+1] == code2[j+m+1]) { 
					m += 1;
				}
				if (k + m + 1 >= maxLines) {
					duplicatedLines += [i-k..(i+m+1)];
					mRem = m + 1 > mRem ? m + 1 : m + 1;
				}
				j += m+1;
			}
			j += 1;
		}
		i += maxLines + mRem;
	}
	return (duplicatedLines);
}

