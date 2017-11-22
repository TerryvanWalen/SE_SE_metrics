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
	return size(duplicatesPerFile);
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