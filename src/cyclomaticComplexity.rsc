module cyclomaticComplexity

import IO;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Prelude;
import String;

public void main() {
	loc project = |project://smallsql0.21_src2|;
	set[Declaration] asts = createAstsFromEclipseProject(project, true);
	visit (asts) {
		case stn:\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl): {
			// here when the method matches I want to know how many lines of code are in the method
			println(stn.src);
			res = computeCC(impl, size(exceptions));
			println("CC for:<name> is <res>");
		}
	}
}

// Computes the Cyclomatic Complexity of a method
// Based on: https://www.leepoint.net/principles_and_practices/complexity/complexity-java-method.html
// Start with a CC of 1 and then add 1 for each of the following:
// Returns	Each return that isn't the last statement of a method. Still TODO
// Selection	if, else, case, default.
// Loops	for, while, do-while, break, and continue.
// Operators	&&, ||, ?, and :
// Exceptions	catch, finally, throw, or throws clause.
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
			CC += 1 + countExpressions(condition);
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

public int countExpressions(Expression expr) {
	int count = 0;
	visit (expr) {	
		case \infix(Expression lhs, str operator, Expression rhs): {	
			if (operator == "&&" || operator == "||")
				count += 1;
		}
	}
	return count;
}