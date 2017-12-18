# University of Amsterdam
## Software Evolution Assignment 2: Clone detection

## Contributors:
 - Nicolae Marian Popa
 - Terry van Walen

## Problem statement
Code cloning is a phenomenon that is of both scientific and practical interest. In the lecture and the related papers, clone detection and management techniques were discussed, as well as the various arguments surrounding the problems that code cloning causes.

Build a clone detection tool which can detect the following types of clones:
 - Type 1: exact matching, ignoring whitespaces and comments
 - Type 2: syntactical copy with changes allowed in variable, type, function or identifiers
 - Type 3: copy with changed, added or deleted statements

## Approach
For this problem we chose to apply the algorithm described in the following paper:

Ira D. Baxter, Andrew Yahin, Leonardo Moura, Marcelo Sant'Anna, Lorraine Bier: *Clone Detection Using Abstract Syntax Trees (AST)*

The algorithm finds clones by comparing sub-trees of the project's AST. Although complexity of such an approach might go up to O(n^4), it is substantially reduced by hashing all the possible subtrees into buckets and then the comparison is done only between the subtrees in the buckets. A hash function which takes into account all elements in a tree will identify only exact matches. In order to account for near-miss clones, a particularly bad hash function can be chosen which does not take into account certain parts of the subtree, such as the leaves.

Similarity between two trees is calculated using the following formula:

Similarity = 2 x S / (2 x S + L + R) where
 - S = number of shared nodes
 - L = number of different nodes in sub-tree 1
 - R = number of different nodes in sub-tree 2

More particularly, we account for near-miss clones by normalizing the Abstract Syntax Tree and transforming the following properties to a single, common value:
 - names of: classes, interfaces, methods, constructors, variable, parameters, enums
 - return types
 - numbers, strings and character literals

Basic algorithm pseudocode:

```
Clones = empty_collection
For each subtree i:
    If mass(i) >= MassThreshold
    Then hash i to bucket
For each subtree i and j in the same bucket
  If CompareTree(i,j) > SimilarityThreshold
  Then {
    For each subtree s of i
      If IsMember(Clones, s)
      Then RemoveClonePair(Clones, s)
      For each subtree s of j
        If IsMember(Clones, s)
        Then RemoveClonePair(Clones, s)
      AddClonePair(Clones, i, j)
  }
```
where SimilarityThreshold is:
 - Type 1: 1.0
 - Type 2: 1.0
 - Type 3: 0.8

## Visualization
Terry, do your magic here

## Testing
We test the following:
 - Similarity between different types of nodes
 - Transitive pairs removal
 - Expected type 1 clones on a small project
 - Expected type 2 clones on a small project
