# University of Amsterdam
## Software Evolution Assignment 1: Software Metrics

## Contributors:
 - Nicolae Marian Popa
 - Terry van Walen

## Metrics:
 - Volume
 - Cyclomatic Complexity
 - Unit size
 - Code duplication
 - Unit interfacing
 - Unit testing

## Volume
We calculate volume by iterating through each file and for every line we determine whether it's a line of code or not.
Things to consider:
 - Empty lines
 - Line comments
 - Block comments
   - Mark the beginning of the block comment
   - Mark the end of the block comment
   - Everything between the two positions is not code
 - One-line block comments
   - We tackle this by removing them using regular expressions
 - Code before and after block comments: 
 ```java
 /**
 * comment
 */code
 code/**
 * comment
 */
 ```

Another way of counting volume is the following, which has much nicer code but it also much slower:
We calculate volume by eliminating any text which is not code and then counting how many lines are left.
Steps for each file:
 - Replace any strings "..." with the * character, in order to avoid identifying any code-like text in them
 - Convert the list of rows to a single string, while still keeping newline(\n) characters
 - Remove block comments with regular expressions
 - Convert back to a list of rows by splitting between the newline(\n) character
 - Remove blank lines
 - Remove line comments

### From numbers to score

| Rank | MY       | Java     | 
| ---- |:--------:|:--------:|
|  ++  | 0-8      | 0-66     |
|  +   | 8-30     | 66-246   |
|  o   | 30-80    | 246-665  |
|  -   | 80-160   | 665-1310 |
|  --  | >160     | >1310    |

### We compute cyclomatic complexity and unit size for each unit in the code, which a single method.

## Cyclomatic complexity
We calculate cyclomatic complexity by visiting every method in the AST tree of the project and then computing the corresponding CC number for the method body.
The algorithm starts with a 1 and then adds 1 for each of the following:
 - Returns: TODO: Each return that isn't the last statement of a method
 - Selection: if, else, case, default
 - Loops: for, while, do-while, break, and continue
 - Operators: &&, || TODO: ?, and :
 - Exceptions: catch, finally, either throw or throws clause

### From numbers to score

| CC    | Risk evaluation             |
| ----- |:---------------------------:|
| 1-10  | simple, without much risk   |
| 11-20 | more complex, moderate risk |
| 21-50 | complex, high risk          |
| >50   | untestable, very high risk  |

| Rank | moderate | high | very high |
| ---- |:--------:|:----:|:---------:|
|  ++  | 25%      | 0%   | 0%        |
|  +   | 30%      | 5%   | 0%        |
|  o   | 40%      | 10%  | 0%        |
|  -   | 50%      | 15%  | 5%        |
|  --  | -        | -    | -         |


## Unit size
We calculate unit size in the same iteration over the AST tree as the cyclomatic complexity. 
We take the method body by reading the source code specified by the src attribute of each node, and then clean the method body using the same steps as in the volume metric.
Finally, the unit size is obtained by counting the number of lines left in the body. 

We got the thresholds from the paper:
*Tiago L.Alvesm Christiaan Ypma, Joost Visser: Deriving Metric Thresholds from Benchmark Data*

### From numbers to score
CC - cyclomatic complexity score

| CC    | Risk evaluation             |
| ----- |:---------------------------:|
| 1-30  | simple, without much risk   |
| 30-44 | more complex, moderate risk |
| 44-74 | complex, high risk          |
| >74   | very high risk              |

| Rank | moderate | high | very high |
| ---- |:--------:|:----:|:---------:|
|  ++  | 25%      | 0%   | 0%        |
|  +   | 30%      | 5%   | 0%        |
|  o   | 40%      | 10%  | 0%        |
|  -   | 50%      | 15%  | 5%        |
|  --  | -        | -    | -         |

## Code duplication
We calculate code duplication as the percentage of all code that occurs more than once in equal code blocks of at least 6 lines. 
When comparing code lines, we trim whitespace. If a single line is repeated many times, but the lines before and after differ every time, we do not count it as duplicated.
If however, a group of 6 lines appears unchanged in more than one place, we count it as duplicated. Apart from removing whitespace, the duplication we measure is an exact string matching duplication. We also count the original lines so two identical files would yield a duplication score of 100%.

What we don't understand from the paper is why not all whitespace is removed from every line because this will yield more duplicated blocks and doesn't take that much longer. Next we would not count the original lines because it's not really fair as a number representing code duplication but it is useful for looking up which lines are part of duplicated code so the programmer can decide what to keep.

| Rank | duplication |
| ---- |:-----------:|
|  ++  | 0-3%        |
|  +   | 3-5%        |
|  o   | 5-10%       |
|  -   | 10-20%      |
|  --  | 20-100%     |

## Unit interfacing
Unit interfacing can negatively impact maintainability, as units with a high number of parameters are harder to instantiate because more knowledge about the context and about each parameters is required. The area of the maintainability index where unit interfacing plays a role is reusability.
We calculate unit interfacing by counting how many methods are in each risk category based on the table below. 

We got the thresholds from the paper:
*Tiago L. Alves, Jose Pedro Correia, Joost Visser: Benchmark-based Aggregation of Metrics to Ratings*

### From numbers to score
UI - number of parameters of a method

| UT    | Risk evaluation             |
| ----- |:---------------------------:|
| <=2   | simple, without much risk   |
| <=3   | more complex, moderate risk |
| <=4   | complex, high risk          |
| >4    | untestable, very high risk  |

## Unit testing
Method calls contribute to code coverage.
We calculate unit testing by counting how many method calls are in each method and how many assert statements there are. They should be kind of similar, because method calls contribute to code coverage and assert conditions test behavior.
TODO: find a good reasoning behind the scoring

### From numbers to score
UT = AC / FC where:
FC: function calls
AC: assert statements

| Rank | UT    |
| ---- |:-----:|
|  ++  | >4    |
|  +   | 2-4   |
|  o   | 1-2   |
|  -   | 0.5-1 |
|  --  | <0.5  |