module cloneDetection

import IO;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Node;
import util::Math;
import Prelude;
import String;
import lang::json::IO;

/**
*	Detects clones using the basic algorithm
*/
public list[set[loc]] detectClones(set[Declaration] asts, int cloneType) {
	println("Detecting clones..");
	int massThreshold = 25;
	list[real] similarityThreshold = [1.0, 1.0, 1.0, 0.8];
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
					buckets = hashNode(normalize(x), buckets, x.src);//for type 2 and 3 we normalize the nodes
				} else {
					buckets = hashNode(x, buckets, mass, x.src);
				}
				
			}
		}
	}
	println("Nodes hashed to buckets..");
	
	for (bucket <- buckets) {
		nodesList = buckets[bucket];
		if (size(nodesList) < 2) continue;	
	
		pairs = [<nodesList[i], nodesList[j]> | i <- [0..size(nodesList)], j <- [i..size(nodesList)], nodesList[i][1] != nodesList[j][1]];		
		for (<x,y> <- pairs) {
			sim = nodeSimilarity(cleanNode(x[0]), cleanNode(y[0]));
			if (sim >= similarityThreshold[cloneType]) {
				//for each member of x remove it from the clones
				visit(x[0]) {	
					case node a: {
						if (a != x[0]) {	
							cloneClasses = removeChilds(cloneClasses, a);
						}										
					}
				}
				visit(y[0]) {
					case node a: {	
						if (a != y[0]) {
							cloneClasses = removeChilds(cloneClasses, a);
						}
					}
				}
				cloneClasses += <x[1], y[1]>;
			}
		}
	}
	
	return applyTrans(cloneClasses);
}

public list[set[loc]] applyTrans(lrel[loc, loc] origClones) {
	list[set[loc]] res = [];
	for (<a,b> <- origClones) {
		res = addCloneToRes(res, <a,b>);
	}
	return res;
}

list[set[loc]] addCloneToRes(list[set[loc]] clones, tuple[loc, loc] b) {	
	int i0 = -1, i1 = -1;
	int i = 0;
	for (clone <- clones) {
		if (b[0] in clone) {
			i0 = i;
		}
		
		if (b[1] in clone) {
			i1 = i;
		}
		i += 1;
	}
	
	if (i0 == i1 && i0 > -1) return clones;	
	
	if (i0 > -1 && i1 > -1) {//merge two
		clones[i0] += clones[i1];
		clones = delete(clones, i1);
	} else if (i0 > -1) {
		clones[i0] += {b[0],b[1]};
	} else if (i1 > -1) {
		clones[i1] += {b[0],b[1]};
	} else {
		clones += [{b[0],b[1]}];
	}
		
	return clones;
}

public map[node, lrel[node, loc]] hashNode(node x, map[node, lrel[node, loc]] buckets, loc ll) {
	node y = cleanNode(x);
	if (buckets[y]?)
		buckets[y] += <x,ll>;
	else
		buckets[y] = [<x,ll>];
	return buckets;
}

/**
* This cleaning is necessary for hashing nodes into buckets
* Rascal went from keeping the fields below as annotations to keeping them directly in the structure
* Two similar pieces of code should hash to the same bucket, but because they have different src values they will be seen as different nodes
*/
private node cleanNode(node n) {
	return unsetRec(n);
}

public list[tuple[loc, loc]] removeChilds(list[tuple[loc, loc]] clones, node n) {
	if (n@src?)
		return [<a,b> | <a,b> <- clones, a != n.src, b != n.src];
	//println("no src field");
	return clones;
}

public void printClones(list[set[loc]] clones) {
	println("<size(clones)> clones found: ");
	for (group <- clones) {
		for (g <- group) {
			println(g);
		}
		println();
	}
}

public str toJson(list[set[loc]] clones) {
	println("Creating JSON: ");
		
	list[map[str, value]] output = [];
	for (group <- clones) {
		list[map[str, value]] imports = [];
		for (g <- group) {
			map[str, value] im = ();
			//im["name"] = g.file;
			
			list[int] slashes = findAll(g.uri, "/");
			
			im["loc"] = substring(g.uri, slashes[1] + 1);
			im["name"] = substring(g.uri, slashes[2] + 1) + "_" + toString(g.begin.line) + "-" + toString(g.end.line);
			im["name_read"] = substring(g.uri, slashes[size(slashes) - 2] + 1) + "_" + toString(g.begin.line) + "-" + toString(g.end.line);
			im["startline"] = g.begin.line;
			im["endline"] = g.end.line;
			imports += im;
		}

		for (int i <- index(imports)) {
			map[str, value] c = imports[i];
			c["imports"] = slice(imports, 0, i) + slice(imports, i+1, size(imports)-i-1);
			output += c;
		}
	}
	
	return toJSON(output, true);
}

private void printBuckets(map[node, lrel[node, loc]] buckets) {	
	println("There are <size(buckets)> buckets");
	for (bucket <- buckets) {
		int size = size(buckets[bucket]);
		if (size > 0) {
			println("<size> elements");
			for (bb <- buckets[bucket]) {
				println(bb[1]);
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
    	case \method(Type r, str s, list[Declaration] p, list[Expression] e) => \method(r, "methodName", p, e)
    	case \constructor(_, p, e, i) => \constructor("constructorName", p, e, i)
    	case \typeParameter(_, list[Type] e) => \typeParameter("typeParameterName", e)
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