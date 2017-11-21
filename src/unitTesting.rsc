module unitTesting

import IO;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import Prelude;
import String;

public str computeUT(loc project) {
		
	set[Declaration] asts = createAstsFromEclipseProject(project, true);
	map[str, int] result = getEmptyComplexityMap();
	
	//extract test classes, which end with Test
	set[Declaration] testClasses = {};
	visit (asts) {
		case cl:\class(str name, list[Type] extends, list[Type] implements, list[Declaration] body): {
			//println("Class name is <name>");
			if (endsWith(name, "Test"))
				testClasses += cl;
		}
	}
	
	int assertPerMethod, totalMethods = 0, mCalls;
	visit(testClasses) {
		case m:\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl): {
			assertPerMethod = 0;
			mCalls = 0;
			totalMethods += 1;
			visit(m) {
				case \assert(Expression expression):
					assertPerMethod += 1;	
				
				case \assert(Expression expression, Expression message):
					assertPerMethod += 1;
				
				case \methodCall(bool isSuper, str name, list[Expression] arguments):
					mCalls += 1;		

				case \methodCall(bool isSuper, Expression receiver, str name, list[Expression] arguments): 
					mCalls += 1; 	
			}
			result[getComplexityUT(assertPerMethod, mCalls)] += 1;
		}
	}
	if (totalMethods > 0) {
		println("Unit testing for <totalMethods> methods:");
		for (a <- result) {
			println("<a>: <result[a]> methods, <percent(result[a], totalMethods)> percent");
			result[a] = percent(result[a], totalMethods);
		}
		println();
		return getGrade(result);
	} 
	println("No test methods! Booh!");
	return "--";
	
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
* Returns the complexity according to the number of assert statements
* TODO: return complexity based on both params
*/
private str getComplexityUT(int aCount, int mCalls) {
	if (aCount <= 2) 
		return "simple";
	if (aCount <= 3)
		return "moderate";
	if (aCount <= 4)
		return "high";
	return "very high";
}