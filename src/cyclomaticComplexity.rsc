module cyclomaticComplexity

import IO;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import Prelude;
import String;
import codeLines;

public map[str, str] compute(int volume, loc project) {
	set[Declaration] asts = createAstsFromEclipseProject(project, true);
	
	map[str, int] resultCC, resultUS;
	resultCC = getEmptyComplexityMap();
	resultUS = getEmptyComplexityMap();
	
	int separate = 0;
	visit (asts) {
		case stn:\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl): {
			cc = computeCC(impl, size(exceptions));
			
			methodSource = linesOfCode(stn.src);
			methodSize = size(methodSource);
			complexityCC = getComplexityCC(cc);
			complexityUS = getComplexityUS(methodSize);
			resultUS[complexityUS] += methodSize;
			resultCC[complexityCC] += methodSize;
		}
	}
	
	println();
	println("Cyclomatic complexity:");
	for (a <- resultCC) {
		println("<a> <resultCC[a]>: lines of code, <percent(resultCC[a], volume)> percent");
		resultCC[a] = percent(resultCC[a], volume);
	}
	println();
	
	println("Unit size complexity");
	for (a <- resultUS) {
		println("<a> <resultUS[a]>: lines of code, <percent(resultUS[a], volume)> percent");
		resultUS[a] = percent(resultUS[a], volume);
	}

	return ("US":getGrade(resultCC), "CC":getGrade(resultUS));
}

private map[str, int] getEmptyComplexityMap() {
	map[str, int] result = ();
	result["simple"] = 0;
	result["moderate"] = 0;
	result["high"] = 0;
	result["very high"] = 0;
	return result;
}

private str getGrade(map[str, int] resultMap) {
	if (resultMap["moderate"] <= 25 && resultMap["high"] == 0 && resultMap["very high"] == 0)
		return "++";
	if (resultMap["moderate"] <= 30 && resultMap["high"] <= 5 && resultMap["very high"] == 0)
		return "+";
	if (resultMap["moderate"] <= 40 && resultMap["high"] <= 10 && resultMap["very high"] == 0)
		return "o";
	if (resultMap["moderate"] <= 50 || resultMap["high"] <= 15 || resultMap["very high"] <= 5)
		return "-";
	return "--";
}

/**
* Returns the complexity according to the cyclomatic complexity number
*/
private str getComplexityCC(int CC) {
	if (CC <= 10) 
		return "simple";
	if (CC <= 20)
		return "moderate";
	if (CC <= 50)
		return "high";
	return "very high";
}

/**
* Returns the complexity according to the cyclomatic complexity number
*/
private str getComplexityUS(int us) {
	if (us <= 30) 
		return "simple";
	if (us <= 44)
		return "moderate";
	if (us <= 74)
		return "high";
	return "very high";
}

// Computes the Cyclomatic Complexity of a method
// Based on: https://www.leepoint.net/principles_and_practices/complexity/complexity-java-method.html
// Start with a CC of 1 and then add 1 for each of the following:
// Returns: Each return that isn't the last statement of a method. Still TODO
// Selection: if, else, case, default.
// Loops: for, while, do-while, break, and continue.
// Operators: &&, ||, ?, and :
// Exceptions: catch, finally, throw, or throws clause.
public int computeCC(Statement statements, int noOfThrows) {
	//println("number of throws clauses: <noOfThrows>");
	int CC = 1;
	CC += noOfThrows;
	visit(statements) {
		case \if(Expression condition, Statement thenBranch): {
			//one for the if and then one for each && and ||
			CC += 1 + countExpressions(condition);
		}	
		case \if(Expression condition, Statement thenBranch, Statement elseBranch): {
			//one for the if, one for the else and then one for each && and ||
			CC += 2 + countExpressions(condition);
		}
		case \case(Expression expression): {
			CC += 1 + countExpressions(expression);
		}
		case defaultCase(): {
			CC += 1;
		}		
		case \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body): {
			CC += 1 + countExpressions(condition);
		}
		case \for(list[Expression] initializers, list[Expression] updaters, Statement body): {
			CC += 1;
		}
		case \while(Expression condition, Statement body): {
			CC += 1 + countExpressions(condition);
		}
		case \do(Statement body, Expression condition): {
			CC += 1 + countExpressions(condition);
		}
		case \break(): {	
			CC += 1;
		}
		case \continue(): {
			CC += 1;
		}
		case \continue(str label): {
			CC += 1;
		}
		case \try(Statement body, list[Statement] catchClauses, Statement \finally): {
			// zero for try, then add one for each catch clause and one for finally
			CC += size(catchClauses) + 1;
		}
		case \try(Statement body, list[Statement] catchClauses): {
			CC += size(catchClauses);
		}
		case \throw(Expression expression): {
			CC += 1;
		}
	}
	return CC;
}

private int countExpressions(Expression expr) {
	int count = 0;
	visit (expr) {	
		case \infix(Expression lhs, str operator, Expression rhs): {	
			if (operator == "&&" || operator == "||")
				count += 1;
		}
	}
	return count;
}