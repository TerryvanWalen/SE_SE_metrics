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
  	
	loc project = |project://smallsql0.21_src|;
	//loc project = |project://hsqldb-2.3.1|;
	//loc project = |project://rascal|; 
	//loc project = |project://smallsql0.21_src|;

	M3 model = createM3FromEclipseProject(project);
	map[loc, list[str]] codeBase = getCleanCodePerFile(files(model));
	int volume  = locInCodeBase(codeBase);
	map[str,str] report = ();
	
	println("<volume> lines of code");
	report["Vol"] = getGradeLOC(volume);//volume in lines of code
	report += compute(volume, project);//adds CC (cyclomati) and US(unit size) keys
	report["Dup"] = computeDup(codeBase, volume);//code duplication
	report["UT"] = computeUT(project);//unit testing
	report["UI"] = computeUI(project);//unit interfacing
	
	println("Volume score: <report["Vol"]>");
	println("Duplication score: <report["Dup"]>");
	println("Unit size score: <report["US"]>");
	println("Cyclomatic complexity score: <report["CC"]>");
	println("Unit testing score: <report["UT"]>");
	println("Unit interfacing score: <report["UI"]>");
	
	int analys = (scoreToInt(report["Vol"]) + scoreToInt(report["Dup"]) + scoreToInt(report["US"]) + scoreToInt(report["US"])) / 4;
	int change = (scoreToInt(report["CC"]) + scoreToInt(report["Dup"])) / 2;
	int stabil = scoreToInt(report["UT"]);
	int testab = (scoreToInt(report["CC"]) + scoreToInt(report["US"]) + scoreToInt(report["UT"])) / 3;
	
	println();
	println("Report:");
	println("Analysability: <intToScore(analys)>");
	println("Changeability: <intToScore(change)>");
	println("Stability: <intToScore(stabil)>");
	println("Testability: <intToScore(testab)>");
	println("Reusability: <report["UI"]>");
				

	datetime end = now();
	Duration elapsedTime = createDuration(st, end);
	println("");
	println("Analysis duration: <elapsedTime[4]> minutes and <elapsedTime[5]> seconds");
	println("*****END*****");
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