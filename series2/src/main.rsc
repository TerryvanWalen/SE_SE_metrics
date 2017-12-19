module main

import IO;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Prelude;
import String;
import DateTime;
import cloneDetection;
import cloneDetectionTest;

public void main() {
	println("*****START*****");
	datetime st = now();
	//loc project = |project://smallsql0.21_src2|;
	//loc project = |project://hsqldb-2.3.1|;
	//loc project = |project://metricsnew|; 
	loc project = |project://smallsql0.21_src|;
	M3 model = createM3FromEclipseProject(project);
	set[Declaration] asts = createAstsFromEclipseProject(project, true);
	int cloneType = 2;

	//printClones(detectClones(asts, cloneType));
	
	str jsonClones = toJson(detectClones(asts, cloneType));
	print(jsonClones);
	
	writeFile(|project://se_clone_detection/output/data.json|,jsonClones);

	datetime en = now();
	println(en - st);
	println("******END******");
}