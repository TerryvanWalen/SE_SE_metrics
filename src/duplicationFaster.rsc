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

public int codeDuplicationInProject(M3 model) {
	set[loc] projectMethods = files(model);
	map[loc, list[str]] methodWithCodes = getCleanCodePerMethod(projectMethods);
	
	int locInMethods = (0 | it + size(methodWithCodes[l]) | l <- methodWithCodes);	
	
	datetime st = now();
	int blockSize = 6;
	map[loc, list[str]] codeBlocks = getBlocksOf(methodWithCodes, blockSize);
	datetime st2 = now();
	list[str] duplicates = getDuplicatedBlocks(codeBlocks);
	datetime st3 = now();
	rel[loc, int] duplicatesPerFile = getDuplicatedLineNumberPerFile(codeBlocks, duplicates, blockSize);
	datetime en = now();
	println(createDuration(st, st2));
	println(createDuration(st2, st3));
	println(createDuration(st3, en));
	println(createDuration(st, en));
	iprintln("<size(duplicatesPerFile)>/<locInMethods> : <size(duplicatesPerFile) / toReal(locInMethods)>");
	return size(duplicatesPerFile);
}


private map[loc, list[str]] getCleanCodePerMethod(set[loc] projectMethods) {
	return (file: linesOfCode(file) | file <- projectMethods);
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
  	if(e notin done) { done = done + {e}; } else {println(e); append e;}
  }
}

private rel[loc, int] getDuplicatedLineNumberPerFile(map[loc, list[str]] codeBlocks, list[str] duplicates, int blockSize) {
	return ({<l, j> | loc l <- codeBlocks, int i <- [0..size(codeBlocks[l])], codeBlocks[l][i] in duplicates, int j <- [i..i+blockSize]});
}