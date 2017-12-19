module cloneDetectionTest

import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;
import lang::java::m3::Core;
import cloneDetection;

public test bool testSimilarity1() {
	node n1 = makeNode("n1", [1,2,3]);
	node n2 = makeNode("n1", [1,2,3]);
	
	real sim = nodeSimilarity(n1, n2);
	return sim == 1.0;
}

public test bool testSimilarity2() {
	node n1 = makeNode("n1", [makeNode("n2",[2]),2,3]);
	node n2 = makeNode("n2", [1,2,3]);
	
	real sim = nodeSimilarity(n1, n2);
	return (sim < 1.0);
}

public test bool testMass() {
	node n1 = makeNode("n1", [makeNode("n2", [2]), 2, makeNode("n3", [3])]);
	return mass(n1) == 3;
}

public test bool testTransitivePairs() {	
	loc l1 = |location://X|;
	loc l2 = |location://Y|;
	loc l3 = |location://Z|;
	println();
	res = applyTrans([<l1, l2>, <l2,l3>]);
	
	return res == [{l1, l2, l3}];
}

public test bool testType1() {
	loc project = |project://smallsql0.21_src2|;
	set[Declaration] asts = createAstsFromEclipseProject(project, true);
	list[set[loc]] clones = detectClones(asts, 1);
	list[set[loc]] expected = [];
	expected += {|project://smallsql0.21_src2/src/CommandLine2.java|(877,539,<45,4>,<62,5>),
				 |project://smallsql0.21_src2/src/CommandLine.java|(802,539,<35,4>,<52,5>)};

	expected += {|project://smallsql0.21_src2/src/CommandLine.java|(1619,106,<58,8>,<62,9>),
				 |project://smallsql0.21_src2/src/CommandLine2.java|(609,106,<30,8>,<34,9>),
				 |project://smallsql0.21_src2/src/CommandLine.java|(384,106,<11,8>,<15,9>)};

	return clones == expected;
}

public test bool testType2() {
	loc project = |project://smallsql0.21_src2|;
	set[Declaration] asts = createAstsFromEclipseProject(project, true);
	list[set[loc]] clones = detectClones(asts, 2);
	
	list[set[loc]] expected = [];
	expected += {|project://smallsql0.21_src2/src/CommandLine.java|(1353,682,<54,4>,<81,5>),
				 |project://smallsql0.21_src2/src/CommandLine.java|(91,699,<6,1>,<33,5>)};

	expected += {|project://smallsql0.21_src2/src/CommandLine2.java|(877,539,<45,4>,<62,5>),
				 |project://smallsql0.21_src2/src/CommandLine.java|(802,539,<35,4>,<52,5>)};

	return clones == expected;
}



public void main() {	
	println("Automated testing framework for cloning detection tool");
}