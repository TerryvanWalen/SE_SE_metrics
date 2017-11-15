module main

import IO;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Prelude;
import String;
import codeLines;
import cyclomaticComplexity;


public void main() {
	//loc project = |project://smallsql0.21_src|;
	loc project = |project://hsqldb-2.3.1|;
	//loc project = |project://rascal|; 
	//loc project = |project://smallsql0.21_src2|;
	int volume = LOCInProject(project);

	println("Volume metric (<volume>): " + ["++", "+", "o", "-", "--"][(0 | it + 1 | x <- [66, 246, 655, 1310], volume >= x*1000)]);
	println("CC metric is <compute(volume, project)>");
}