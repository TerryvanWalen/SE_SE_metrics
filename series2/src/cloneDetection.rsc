module cloneDetection

import IO;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import Prelude;
import String;

/**
*	Detects clones using the basic algorithm
*/
public list[tuple[loc, loc]] detectClones(set[Declaration] asts, int cloneType) {
	println("Detecting clones..");
	int massThreshold = 30;
	real similarityThreshold = 1.0;
	clones = ();
	map[node, lrel[node, loc]] buckets = ();
	lrel[loc, loc] cloneClasses = [];
	
	//hash nodes to buckets
	println("Hashing nodes to buckets..");
	visit(asts) {
		case node x: {
			int mass = mass(x);
			if (mass >= massThreshold && x@src?) {
				if (cloneType > 1) {
					buckets = hashNode(normalize(x), buckets, mass, x.src);	
				} else {
					buckets = hashNode(x, buckets, mass, x.src);
				}
				
			}
		}
	}
	println("Nodes hashed to buckets..");
	printBuckets(buckets);
	
	for (bucket <- buckets) {
		nodesList = buckets[bucket];
		if (size(nodesList) < 2) continue;	
	
		pairs = [<nodesList[i], nodesList[j]> | i <- [0..size(nodesList)], j <- [i..size(nodesList)], nodesList[i][1] != nodesList[j][1]];		
		for (<x,y> <- pairs) {
			
			sim = nodeSimilarity(x[0], y[0]);
			//println("similarity for <x[0].src> and <y[0].src> is <sim>");
			//println(x[0]);
			//println(y[0]);		
			if (sim >= similarityThreshold) {
				//for each member of x remove it from the clones
				visit(x[0]) {	
					case node a: {
						if (a != x[0] && a@src?)
							cloneClasses = removeChilds(cloneClasses, a);						
					}
				}
				visit(y[0]) {	
					case node a: {
						if (a != y[0] && a@src?)
							cloneClasses = removeChilds(cloneClasses, a);						
					}
				}
				cloneClasses += <x[1], y[1]>;
			}
		}
	}
	
	//printClones(cloneClasses);
	return cloneClasses;
}

//TODO: at the moment they are hashed by mass. is this correct?
public map[node, lrel[node, loc]] hashNode(node x, map[node, lrel[node, loc]] buckets, int mass, loc ll) {
	x = cleanNode(x);
	if (buckets[x]?)
		buckets[x] += <x,ll>;
	else
		buckets[x] = [<x,ll>];
	return buckets;
}

/**
* This cleaning is necessary for hashing nodes into buckets
* Rascal went from keeping the fields below as annotations to keeping them directly in the structure
* Two similar pieces of code should hash to the same bucket, but because they have different src values they will be seen as different nodes
*/
private node cleanNode(node n) {
	return visit(n) {
		case Declaration x : {
			x.src = unknownSource;
			x.decl = unresolvedDecl;
			x.typ = \any();
			x.modifiers = [];
			x.messages = [];
			insert x;
		}
		case Statement x : {
			x.src = unknownSource;
			x.decl = unresolvedDecl;
			insert x;
		}
		case Expression x : {
			x.src = unknownSource;
			x.decl = unresolvedDecl;
			x.typ = \any();
			insert x;
		}
		case Type x : {
			x.name = unresolvedType;
			x.typ = \any();
			insert x;
		}	
	}
}

public list[tuple[loc, loc]] removeChilds(list[tuple[loc, loc]] clones, node n) {
	//println("removing for <n.src>");
	return [<a,b> | <a,b> <- clones, a != n.src, b != n.src];
}

public void printClones(list[tuple[loc, loc]] clones) {
	println("Clones found: ");
	for (<a, b> <- clones) {
		println(a);
		println(b);
		println();
	}
}

private void printBuckets(map[node, lrel[node, loc]] buckets) {	
	println("There are <size(buckets)> buckets");
	for (bucket <- buckets) {
		int size = size(buckets[bucket]);
		if (size > 0) {
			println("<size> elements");
			for (bb <- buckets[bucket]) {
				if (bb[0]@src?)	
					println(bb[0].src);
				else
					println("no src field: <bb[1]>");
			}
		}
	}
}

/**
* Normalize a node for type 2 and 3 clones
* Modify the name of the following structures to a unique one
* TODO: replace return types?
* TODO: replace numbers, boolean values, strings and char literals?
*/
private node normalize(node n) {
	return visit(n) {
		case \enum(_, i, c, b) => \enum("enumName", i, c, b)
    	case \enumConstant(_, a, c) => \enumConstant("enumConstant", a, c)
    	case \enumConstant(_, a) => \enumConstant("enumConstant", a)
    	case \class(_, e, i, b) => \class("class", e, i, b)
    	case \interface(_, e, i, b) => \interface("interfaceName", e, i, b)
    	case \method(r, _, p, e, i) => \method(r, "methodName", p, e, i)
    	//case \method(r, _, p, e) => \method(r, "methodName", p, e)
    	case \constructor(_, p, e, i) => \constructor("constructorName", p, e, i)
    	case \typeParameter(_, e) => \typeParameter("typeParameterName", e)
    	case \annotationTypeMember(t, _) => \annotationTypeMember(t, "annotationTypeMemberName") 			
    	case \annotationTypeMember(t, _, d) => \annotationTypeMember(t, "annotationTypeMemberName", d)
    	case \parameter(t, _, e) => \parameter(t, "parameterName", e)
    	case \vararg(x, _) => \vararg(x, "varArgName")
    	case \variable(_, e) => \variable("variableName", e)
    	case \variable(_, e, i) => \variable("variableName", e, i)
    	case \characterLiteral(_) => \characterLiteral("c")
    	case \number(_) => \number("1")
    	case \booleanLiteral(_) => \booleanLiteral(false)
    	case \stringLiteral(_) => \stringLiteral("string")
	}
}

public int mass(node n) {
	int mass = 0;
	visit(n) {
		case node _ : mass += 1;
	}
	return mass;
}

/**
* Calculate similarity of two nodes based on the formula:
* similarity = 2 x S / (2 x S + L + R) where:
* S = number of shared nodes 
* L = number of different nodes in sub-tree 1
* R = number of different nodes in sub-tree 2
*/
public real nodeSimilarity(node x, node y) {
	list[node] xN = [];
	list[node] yN = [];
	
	visit (x) {
		case node n: xN += n;
	}
	
	visit (y) {
		case node n: yN += n;
	}
	
	S = size(xN & yN);
	L = size(xN - yN);
	R = size(yN - xN);
	return (2.0 * S) / (2.0 * S + L + R);
}