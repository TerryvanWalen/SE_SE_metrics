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
	loc project = |project://smallsql0.21_src2|;
	//loc project = |project://hsqldb-2.3.1|;
	//loc project = |project://metricsnew|; 
	//loc project = |project://smallsql0.21_src|;
	M3 model = createM3FromEclipseProject(project);
	set[Declaration] asts = createAstsFromEclipseProject(project, true);
	int cloneType = 2;

	//printClones(detectClones(asts, cloneType));
	
	str jsonClones = toJson(detectClones(asts, cloneType));
	print(jsonClones);
	
	writeFile(|project://se_clone_detection/output/data.json|,jsonClones);

	//visit(asts) {
	//	case x:\method(q,r,t,y,z): {
	//		println(q);
	//		println(r);
	//		println(t);
	//		println(y);
	//		println("first case!");
	//		if (x@src?)
	//			println(x.src);
	//		else
	//			println("no src found for <x>");
	//	}
	//	case x:\method(a,b,c,d,e): {
	//		println(b);
	//		println("second case!");
	//		if (x@src?)
	//			println(x.src);
	//		else
	//			println("no src found for <x>");
	//	}
	//	case x:\class(q,r,t,y): {
	//		if (x@src?)
	//			println(x.src);
	//		else
	//			println("no src found for <x>");
	//	}
	//	case x:\class(q): {
	//		if (x@src?)
	//			println(x.src);
	//		else
	//			println("no src found for <x>");
	//	}
	//}
	
	
	datetime en = now();
	println(en - st);
	println("******END******");
}