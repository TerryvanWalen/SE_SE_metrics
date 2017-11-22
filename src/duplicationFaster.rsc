module duplicationFaster

import IO;
import Prelude;
import String;
import Map;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import codeLines;

public str computeDup(map[loc, list[str]] codeBase, int volume) {
	int duplicates = computeDup(codeBase); 
	real dup = (duplicates / toReal(volume)) * 100;
	print("Duplication for <volume> lines of code:\n<duplicates> recurring  lines, <round(dup, 0.1)> percent\n\n");
	return ["++", "+", "o", "-", "--"][(0 | it + 1 | x <- [3, 5, 10, 20], dup >= x)];;
}

public int computeDup(map[loc, list[str]] codeBase) {
	int blockSize = 6;
	map[loc, list[str]] codeBlocks = getBlocksOf(codeBase, blockSize);
	list[str] duplicates = getDuplicatedBlocks(codeBlocks);
	rel[loc, int] duplicatesPerFile = getDuplicatedLineNumberPerFile(codeBlocks, duplicates, blockSize);
	//iprint(toMap(duplicatesPerFile));
	map[loc, list[str]] dupMap = duplicatedCodeBlockstoLoc(toMap(duplicatesPerFile), codeBase);
	iprint(dupMap);
	int nondups = countNonDuplicateCodeofSize(dupMap, blockSize);
	int locInMethods = (0 | it + 1 | l <- dupMap, s <- dupMap[l]);
	println(locInMethods - nondups);
	//iprint(dupMap);
	//print("\ndups: <nondups>\n\n");
	return size(duplicatesPerFile);
}



private map[loc, list[str]] duplicatedCodeBlockstoLoc(map[loc, set[int]] ms, map[loc, list[str]] code) {
	map[loc, list[int]] msSorted = (n: sort(ms[n]) | n <- ms);
	map[loc, list[str]] ret = ();
	for (n <- ms) {
		list[int] lst = msSorted[n];
		int prev = head(lst);
		for (int i <- drop(2, index(lst)), i < size(lst)) {
			if (lst[i] != lst[i-1] +1) { ret += (createLoc(n, prev, lst[i-1]) : slice(code[n], prev, lst[i-1]-prev+1)); prev = lst[i]; }
		}
		ret += (createLoc(n, prev, lst[size(lst)-1]) : slice(code[n], prev, lst[size(lst)-1]-prev+1));
	}
	return ret;
}

private loc createLoc(loc l, int l1, int l2) {
	return l(l1,l2);
}

private map[loc, list[str]] getBlocksOf(map[loc, list[str]] ms, int maxLines) {
	map[loc, list[str]] newms = ();
	for (m <- ms) {
		newms[m] = ([] | it + intercalate("\n", slice(ms[m], i, maxLines)) | i <- index(ms[m]), i + maxLines < size(ms[m]));
	}
	return newms;
}

private list[str] getDuplicatedBlocks(map[loc, list[str]] codeBlocks) {
	list[str] allBlocks = ([] | it + codeBlocks[b] | b <- codeBlocks);
	return ndup(allBlocks);
}

public list[&T] ndup(list[&T] lst) {
  done = {};
  return for (e <- lst) {
  	if(e notin done) { done = done + {e}; } else {append e;}
  }
}

private rel[loc, int] getDuplicatedLineNumberPerFile(map[loc, list[str]] codeBlocks, list[str] duplicates, int blockSize) {
	return ({<l, j> | loc l <- codeBlocks, int i <- [0..size(codeBlocks[l])], codeBlocks[l][i] in duplicates, int j <- [i..i+blockSize]});
}


private int countNonDuplicateCodeofSize(map[loc, list[str]] methodWithCode, int maxLines) {
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
		
		println("<i+1>/<size(ms)> - <size(code1) - (size([0..size(code1)] - duplicatedCodeInCode1))>/<size(code1)>");
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
	
	int sizeCode1 = size(code1);
	int sizeCode2 = size(code2);
	int mRem = 0;
	int i = max;
	while (i < sizeCode1) {		
		line1 = code1[i];
		
		int j = sameFile ? i+1 : max;
		while (j < sizeCode2 - 1) {
			line2 = code2[j];

			if (line1 == line2) {
				int k = 0;
				while (k + 1 < maxLines && j-k-1 >= 0 && code1[i-k-1] == code2[j-k-1]) { 
					k += 1;
				}
				int m = 0;
				while ((i+m+1 < sizeCode1 && j+m+1 < sizeCode2) && code1[i+m+1] == code2[j+m+1]) { 
					m += 1;
				}
				if (k + m + 1 >= maxLines) {
					duplicatedLines += [i-k..(i+m+1)];
					mRem = m + 1 > mRem ? m + 1 : mRem;
				}
				j += k + m;
			}
			j += 1;
		}
		i += maxLines + mRem;
	}
	return (duplicatedLines);
}