module main

import IO;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Prelude;
import String;

import codeLines;

public void main() {
	M3 model = createM3FromEclipseProject(|project://smallsql0.21_src2|);
	set[loc] allProjectFiles = files(model);
	
	int volume = size(extractCodeFromFiles(allProjectFiles));
	println("Volume metric (<volume>): " + ["++", "+", "o", "-", "--"][(0 | it + 1 | x <- [66, 246, 655, 1310], volume >= x*1000)]);
}