module duplication

import IO;
import Prelude;
import String;

import codeLines;

public int countCodeDuplication(set[loc] projectMethods) {
	map[loc, list[str]] methodWithCodes = getCleanCodePerMethod(projectMethods);
	map[loc, list[str]] validMethodWithCodes = extractMethodsSmallerThanNumLines(methodWithCodes, 6);
	//Count duplicate code in methods
	int nonDuplicatedCode = countNonDuplicateCodeofSize(validMethodWithCodes, 6);
	
	allMethodLines = 0;
	for (l <- methodWithCodes) {
		list[str] code = methodWithCodes[l];
		allMethodLines += size(code);
	}
	
	smallMethodsLines = 0;
	for (l <- validMethodWithCodes) {
		list[str] code = validMethodWithCodes[l];
		smallMethodsLines += size(code);
	}
	
	println("<nonDuplicatedCode+(allMethodLines-smallMethodsLines)>/<allMethodLines>");
	return 0;
}

private map[loc, list[str]] getCleanCodePerMethod(set[loc] projectMethods) {
	map[loc, list[str]] codeLines = ();
	for (file <- projectMethods) {
		list[str] lines = extractCodeFromFiles(file);
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
	iprintln(ms);
	for (int i <- [0..size(ms)]) {
	//l1 <- methodWithCode)
		list[int] duplicatedCodeInCode1 = [];
		list[str] code1 = methodWithCode[ms[i]];
		for (int j <- [(i+1)..size(ms)]) {
			list[str] code2 = methodWithCode[ms[j]];
			duplicatedCodeInCode1 += getDuplicatedLinesOfSize(code1, code2, maxLines);
		}
		
		iprintln([0..size(code1)] - duplicatedCodeInCode1);
		unDuplicatedLines += size([0..size(code1)] - duplicatedCodeInCode1);
	}
	return unDuplicatedLines;
}

private list[int] getDuplicatedLinesOfSize(list[str] code1, list[str] code2, int maxLines)
{
	list[int] duplicatedLines = [];
	for (int i <- [0..size(code1) - maxLines]) {
		str line1 = code1[i];

		for (int j <- [0..size(code2) - maxLines]) {
			str line2 = code2[j];
			
			//println("<i>: <line1> | <line2>");
			if (line1 == line2) {
				int k = 0;
				while ((i+k < size(code1) - 1 || j+k < size(code2) - 1) && code1[i+k] == code2[j+k]) { 
					//println("<i>: <code1[i+k]> | <code2[j+k]>");
					k += 1;
				}
				if (k >= maxLines) {
					duplicatedLines += [i..(i+k)];
					i += k;
				}
			}
		}
	}
	iprintln("<duplicatedLines>");
	iprintln([0..size(code1)] - duplicatedLines);
	return (duplicatedLines);
}