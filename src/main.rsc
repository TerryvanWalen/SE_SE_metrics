module main

import IO;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Prelude;
import String;

import codeLines;
import duplication;
import cyclomaticComplexity;

public void main() {
	loc project = |project://smallsql0.21_src|;
	//loc project = |project://hsqldb-2.3.1|;
	//loc project = |project://rascal|; 
	//loc project = |project://smallsql0.21_src2|;
	M3 model	= createM3FromEclipseProject(project);
	int volume = LOCInProject(model);
	println("<volume> lines of code");
	map[str,str] report = ();

	volumeScore = ["++", "+", "o", "-", "--"][(0 | it + 1 | x <- [66, 246, 655, 1310], volume >= x*1000)];
	report["Vol"] = volumeScore;
	report += compute(volume, project);//adds CC (cyclomati) and US(unit size) keys
	report["Dup"] = "+";
	report["UT"] = "+";//unit testing
	
	int analys = (scoreToInt(report["Vol"]) + scoreToInt(report["Dup"]) + scoreToInt(report["US"]) + scoreToInt(report["US"])) / 4;
	int change = (scoreToInt(report["CC"]) + scoreToInt(report["Dup"])) / 2;
	int stabil = scoreToInt(report["UT"]);
	int testab = (scoreToInt(report["CC"]) + scoreToInt(report["US"]) + scoreToInt(report["UT"])) / 3;
	
	println("Report");
	println("Analysability: <intToScore(analys)>");
	println("Changeability: <intToScore(change)>");
	println("Stability: <intToScore(stabil)>");
	println("Testability: <intToScore(testab)>");
	println("Volume metric (<volume>): " + volumeScore);
	
	println("CC metric is <compute(volume, project)>");
	
	//int duplication = codeDuplicationInProject(model);
	//add score to the report map with the Dup key
}

public int scoreToInt("++") = 5;
public int scoreToInt("+") = 4;
public int scoreToInt("o") = 3;
public int scoreToInt("-") = 2;
public int scoreToInt("--") = 1;

public str intToScore(5) = "++";
public str intToScore(4) = "+";
public str intToScore(3) = "o";
public str intToScore(2) = "-";
public str intToScore(1) = "--";