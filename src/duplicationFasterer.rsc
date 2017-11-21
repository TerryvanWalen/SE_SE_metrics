module duplicationFasterer

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
	iprintln("start");
	datetime st = now();
	
	set[loc] projectMethods = methods(model);
	map[loc, list[str]] methodWithCodes = getCleanCodePerMethod(projectMethods);

	datetime md = now();
	int blockSize = 6;
	map[loc, str] sixBlocks = getBlocksOfSix(methodWithCodes, blockSize);
	iprintln(invert(sixBlocks));
	//list[str] ds = ([] | it + sixBlocks[b] | b <- sixBlocks) - dup(([] | it + sixBlocks[b] | b <- sixBlocks));
	//rel[loc, int] duplicatesPerFile = {<l, j> | loc l <- sixBlocks, int i <- [0..size(sixBlocks[l])], sixBlocks[l][i] in ds, int j <- [i..i+blockSize]};
	////iprintln(sort(duplicatesPerFile));
	//iprintln(size(duplicatesPerFile));
	//iprintln(ds);
	//iprintln(sixBlocks);
	datetime en = now();
	println(createDuration(st, md));
	println(createDuration(md, en));
	println(createDuration(st, en));
	return 0;
}

private map[loc, str] getBlocksOfSix(map[loc, list[str]] ms, int maxLines) {
	map[loc, str] newms = ();
	newms += (m : intercalate("\n", slice(ms[m], i, maxLines)) | m <- ms, i <- index(ms[m]), i + maxLines < size(ms[m]));
	iprintln(newms);
	return newms;
}



private map[loc, list[str]] getCleanCodePerMethod(set[loc] projectMethods) {
	map[loc, list[str]] codeLines = (file: linesOfCode(file) | file <- projectMethods);
	return codeLines;
}