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
public list[tuple[loc, loc]] detectClones(set[Declaration] asts) {
	println("Detecting clones..");
	int massThreshold = 20;
	real similarityThreshold = 1.0;
	clones = ();
	map[node, list[node]] buckets = ();
	
	//hash nodes to buckets
	println("Hashing nodes to buckets..");
	visit(asts) {
		case node x: {
			int mass = mass(x);
			if (mass >= massThreshold) {
				//println("hashing node");
				//println(x);
				buckets = hashNode(x, buckets, mass);
			}
		}
	}
	println("Nodes hashed to buckets..");
	println("There are <size(buckets)> buckets");
	for (bucket <- buckets) {
		println("<size(buckets[bucket])> elements");
	}
	
	//for (bucket <- buckets) {
	//	nodesList = buckets[bucket];
	//	//for (b <- buckets[bucket])
	//	//	println(b.src);
	//	if (size(nodesList) < 2) continue;	
	//	//println("investigating key <bucket>..");
	//	pairs = [<nodesList[i], nodesList[j]> | i <- [0..size(nodesList)], j <- [i..size(nodesList)]];
	//	println("pairs built");
	//	println("computing pair-wise similarity");
	//	for (<x,y> <- pairs) {
	//		sim = nodeSimilarity(x, y);
	//		println("comparing <x.src> and <y.src>"); 
	//		//println("similarity is: <sim>");
	//		//if (sim >= similarityThreshold) {
	//		//	println("found similar trees");
	//		//	//for each member of x remove it from the clones
	//		//	println(x.src);
	//		//	println(y.src);
	//		//}
	//	}
	//	println("pair-wise similarity done");
	//}
	
	//for (b <- buckets) {
	//	println("<b> and <buckets[b]>");
	//}
	return [];
}

public map[int, list[int]] hashh(int x, map[int, list[int]] buckets) {
	if (buckets[x]?)
		buckets[x] += x;
	else
		buckets[x] = [x];
	return buckets;
}

//TODO: at the moment they are hashed by mass. is this correct?
public map[node, list[node]] hashNode(node x, map[node, list[node]] buckets, int mass) {
	if (buckets[x]?)
		buckets[x] += x;
	else
		buckets[x] = [x];
	return buckets;
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

//TODO: rename every method call, class bla bla
public void normalizeNode(node x) {
	return x;
}