module main

import IO;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Prelude;
import String;
import DateTime;

import codeLines;
import duplicationFaster;
import cyclomaticComplexity;
import unitInterfacing;
import unitTesting;


public void main() {
	datetime st = now();
	println("*****START*****");
  	println(printTime(st, "HH:mm:ss"));
  	
	loc project = |project://smallsql0.21_src|;
	//loc project = |project://hsqldb-2.3.1|;
	//loc project = |project://rascal|; 
	//loc project = |project://smallsql0.21_src|;

	M3 model	= createM3FromEclipseProject(project);
	//int volume = LOCInProject(model);
	//println("<volume> lines of code");
//	map[str,str] report = ();
//
//	volumeScore = ["++", "+", "o", "-", "--"][(0 | it + 1 | x <- [66, 246, 655, 1310], volume >= x*1000)];
//	report["Vol"] = volumeScore;
//	report += compute(volume, project);//adds CC (cyclomati) and US(unit size) keys
//	report["Dup"] = "+";//code duplication
//	report["UT"] = computeUT(project);
//	report["UI"] = computeUI(project);
//	
//	println("Volume score: <report["Vol"]>");
//	println("Unit size score: <report["US"]>");
//	println("Cyclomatic complexity score: <report["CC"]>");
//	println("Unit testing score: <report["UT"]>");
//	println("Unit interfacing score: <report["UI"]>");
//	
//	int analys = (scoreToInt(report["Vol"]) + scoreToInt(report["Dup"]) + scoreToInt(report["US"]) + scoreToInt(report["US"])) / 4;
//	int change = (scoreToInt(report["CC"]) + scoreToInt(report["Dup"])) / 2;
//	int stabil = scoreToInt(report["UT"]);
//	int testab = (scoreToInt(report["CC"]) + scoreToInt(report["US"]) + scoreToInt(report["UT"])) / 3;
//	
//	println();
//	println("Report");
//	println("Analysability: <intToScore(analys)>");
//	println("Changeability: <intToScore(change)>");
//	println("Stability: <intToScore(stabil)>");
//	println("Testability: <intToScore(testab)>");
//	println("Reusability: <report["UI"]>");
	
	int duplication = codeDuplicationInProject(model);
	println(duplication);
	
	datetime end = now();
	println(printTime(end, "HH:mm:ss"));
	println("Analysis duration: <createDuration(st, end)>");
	println("duration(int years, int months, int days, int hours, int minutes, int seconds, int milliseconds)");
	println("*****END*****");
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