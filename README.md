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

## Volume
We calculate volume by eliminating any text which is not code and then counting how many lines are left.
Steps for each file:
 - Replace any strings "..." with the * character, in order to avoid identifying any code-like text in them
 - Convert the list of rows to a single string, while still keeping newline(\n) characters
 - Remove block comments with regular expressions
 - Convert back to a list of rows by splitting between the newline(\n) character
 - Remove blank lines
 - Remove line comments

### From numbers to score

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

### From numbers to score
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
When comparing code lines, we ignore leading spaces. So, if a single line is repeated many times, but the lines before and after differ every time, we do not count it as duplicated.
If however, a group of 6 lines appears unchanged in more than one place, we count it as duplicated. Apart from removing leading spaces, the duplication we measure is an exact string matching duplication.

| Rank | duplication |
| ---- |:-----------:|
|  ++  | 0-3%        |
|  +   | 3-5%        |
|  o   | 5-10%       |
|  -   | 10-20%      |
|  --  | 20-100%     |