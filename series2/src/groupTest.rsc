module groupTest

import Set;
import List;
import IO;
import Prelude;

lrel[int, int] cloneClasses = [];

public bool similar(list[int] a, list[int] b) {
	for (i <- a)
		if (indexOf(b, i) > -1)
			return true;
	return false;
}

void main() {
	list[set[int]] new = [];
	new = [{7,8},{3,4},{2,5}];
	new = addPairToList(new, <100,111>);
	println(new);
	new = addPairToList(new, <5,3>);
	println(new);
	new = addPairToList(new, <5,3>);
	println(new);
	new = addPairToList(new, <5,7>);
	println(new);
	new = addPairToList(new, <5,3>);
	println(new);
	new = addPairToList(new, <5, 111>);
	println(new);	
}

list[set[int]] addPairToList(list[set[int]] clones, tuple[int, int] b) {	
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