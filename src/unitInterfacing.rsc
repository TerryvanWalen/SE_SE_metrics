module unitInterfacing

import IO;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import Prelude;
import String;

public str computeUI(loc project) {

	set[Declaration] asts = createAstsFromEclipseProject(project, true);
	int totalMethods = 0;
	int noOfParams;
	map[str, int] result = getEmptyComplexityMap();
	
	visit (asts) {
		case stn:\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl): {
			totalMethods += 1;
			noOfParams = size(parameters);
			result[getComplexityUI(noOfParams)] += 1;
		}
	}
	
	println("Unit interfacing for <totalMethods> methods:");
	for (a <- result) {
		println("<a>: <result[a]> methods, <percent(result[a], totalMethods)> percent");
		result[a] = percent(result[a], totalMethods);
	}
	println();
	return getGrade(result);
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
* Returns the complexity according to the number of unit parameters
*/
private str getComplexityUI(int pCount) {
	if (pCount <= 2) 
		return "simple";
	if (pCount <= 3)
		return "moderate";
	if (pCount <= 4)
		return "high";
	return "very high";
}