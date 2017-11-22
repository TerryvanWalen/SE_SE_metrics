# University of Amsterdam
## Software Evolution Assignment 1: Software Metrics

## Contributors:
 - Nicolae Marian Popa
 - Terry van Walen

## SIG Evaluation Criteria

|               | Volume | Duplication | Unit Size | Unit complexity | Unit interfacing |
| --------------|:------:|:-----------:|:---------:|:---------------:|:----------------:|
| Analysability | x      | x           | x         |                 |                  |
| Modifiability |        | x           |           | x               |                  |
| Testability   | x      |             |           | x               |                  |
| Reusability   |        |             | x         |                 | x                |

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

Another way of counting volume is the following, which has much nicer code but it also much slower.

Calculate volume by eliminating any text which is not code and then counting how many lines are left.
Steps for each file:
 - Replace all strings with \* in order to avoid identifying any multiline comments in them: "any string like this" -> "\*"
 - Convert the list of rows to a single string, while still keeping newline characters(\n)
 - Remove block comments with regular expressions
 - Convert back to a list of rows by splitting between the newline(\n) character
 - Remove blank lines
 - Remove line comments

#### Validation
Testing was done by keeping a separate Eclipse project with a single class but which tried to cover all corner cases of this metric.
To validate our results our results we used two external tools:
 - cloc-1.74
   - During the development process we found that cloc does not cover the case illustrated in the code above, where a line of code occurs right after a block comment ends, but on the same line.
 - LocMetrics

### From numbers to score

| Rank | MY       | Java (KLOC) |
| ---- |:--------:|:-----------:|
|  ++  | 0-8      | 0-66        |
|  +   | 8-30     | 66-246      |
|  o   | 30-80    | 246-665     |
|  -   | 80-160   | 665-1310    |
|  --  | >160     | >1310       |

### We compute cyclomatic complexity and unit size for each unit in the code, which a single method.

## Cyclomatic complexity
We calculate cyclomatic complexity by visiting every method in the AST tree of the project and then computing the corresponding CC number for the method body.
The algorithm starts with a 1 and then adds 1 for each of the following:
 - Selection: if, else, case, default
 - Loops: for, while, do-while, break, and continue
 - Operators: &&, ||, ? and :
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
US - Unit Size score

| US    | Risk evaluation             |
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
Duplicated code is all code that is repeated (exact string match) in consecutive blocks of at least 6 lines. In the example below the lines starting with an asterisk represent the duplicated lines.

*For all code examples below we use a blocksize of 3 to increase readability.*

##### Defining the duplication score
The code duplication score is calculated as the percentage of all the lines of code that occur more than once in blocks of at least 6 consecutive lines of code. The code duplication score for file 1 and file 2 (with a blocksize of 3) would result in a duplication of: 8 out of 10 lines, 80%.

Another metric that could be used is to define the duplication score as the increase in volume that is caused by duplicated code. In the example below this scoring would result in a duplication of: 4 out of 10 lines, 40%. In other words, 40% of the code could be removed for the program to still function.

The first method is chosen primarily because it is useful for the programmer to know how many lines he has to check and where the duplicated lines of code reside and this information is easily accessible from the first metric. With this metric two identical files would yield a duplication score of 100% while the second metric would yield a duplication score of 50%.

```java
//File 1:
  int a = 1;
* int b = 2;
* int c = 3;
* int d = 4;
* int e = 5;


//File 2:
* int b = 2;
* int c = 3;
* int d = 4;
* int e = 5;
  int z = 6;
```

##### What to do with non-code
The code duplication for file 3 and file 4 (similar to file1 and file2) is not different from that of file 1 and file 2 because comments, multiline comments and blank lines are removed from the code before code duplication is calculated.
```java
//File 3:
/* multineline comments
 * are excluded/
 */
//Inline comments are also excluded

int a = 1;
int b = 2;
int c = 3;
int d = 4;
int e = 5;

//File 4:
/* multineline comments
 * are excluded/
 */
//Inline comments are also excluded

int b = 2;
int c = 3;
int d = 4;
int e = 5;
int z = 6;
```

##### What to do with whitespace
Lines are also trimmed, line 1 and line 2 are interpreted as duplicate lines. This is done because codeblocks could be repeated in for example an if statement that indents the code but this doesn't change the code itself.

Line 3 and line 4 on the other hand are not interpreted as duplicate lines because not all whitespace is removed, only leading and trailing whitespace. This is mainly a performance decision and could easily be implemented but we are mainly looking for copy paste duplication and therefore it is not implemented.
```java
1.    int a = 1;
2. int a = 1;

3. int b = 1;
4. int b =  1;
```
##### Imports
We do include imports in our duplication score because there is no clear reason to disregard them. It could certainly be argued that they are not part of the code but it could also be that programmers just copy paste the imports from a previous file without checking if they are really needed and this could be found with this metric, therefore we do include the imports.

##### Brackets
We do include individual brackets as lines of code simply because we are aiming for a simple and fast algorithm to detect copy-paste code. This could result in false positives for cases that include a lot of brackets like a case where 6 if statements are nested while at some other point another nested if statement also ends with 6 lines of closing brackets. In the example below the closing brackets will be counted as duplicate lines. But again it could be argued that finding this lines is desirable behaviour.
```java
if (a==b) {
  if (a==c) {
    if (a==d) {
      if (a==e) {
        if (a==f) {
          if (a==g) {
              int a = b;
          }  
        }  
      }  
    }  
  }  
}
if (b==a) {
  if (b==c) {
    if (b==d) {
      if (b==e) {
        if (b==f) {
          if (b==g) {
              int b = a;
          }  
        }  
      }  
    }  
  }  
}
```

##### Block duplication, not line duplication
In the next example the duplication score is 0%, even though line b appears three times. The metric is only looking at blocks of code that are duplicated. So if a single line is repeated many times, but the lines before or after differ every time, we do not count it as duplicated.
```java
int b = 1;
int c = 2;

int b = 1;
int d = 3;

int b = 1;
int e = 4;
```
##### Results based on the example Projects
Assuming the files are clean (no comments and blank lines). Calculating the duplication score takes an average of 0.86 ± 0.01 seconds for the SmallSql project and 15.7 ± 0.4 seconds for the HsqDB project.

| Project  | 1   | 2   | 3   | 4   | 5   || avg (s) | stdev |
| - | - | - | - | - | - || - | - |
| SmallSql | 0.868 | 0.864 | 0.860 | 0.845 | 0.848 || 0.86 | 0.01 |
| HsqlDB   | 15.35 | 15.92 | 15.25 | 16.11 | 15.94 || 15.7 | 0.4 |



##### The rank we assign based on the duplication score
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

| UI    | Risk evaluation             |
| ----- |:---------------------------:|
| <=2   | simple, without much risk   |
| <=3   | more complex, moderate risk |
| <=4   | complex, high risk          |
| >4    | untestable, very high risk  |

## Unit testing
Method calls contribute to code coverage, while assert statements contribute to behavior testing.
We calculate unit testing by computing the ratio between the number of method calls and the number of assert statements. Counting the two values is done by visiting the AST tree.

The hsqldb project scores very low on unit testing, because it uses JUnit and all assert statements are encapsulated.

### From numbers to score
Our reasoning is that a system which has a similar number of assert statements and method calls (ratio is 1 to 2) falls in the neutral area, as there can be at least one assert per function call. But this does not mean that this ratio can't be achieved by writing many asserts which deal with one function call and ignore the others. Having more than double asserts puts the system in the + area, while having more than 4 times asserts as function calls is what we consider the best situation.

Paper *Mauricio Finavaro Aniche, Gustavo Ansaldi Oliva, Marco Aurélio Gerosa: What Do The Asserts in a Unit Test Tell Us About Code Quality? A Study on Open Source and Industrial Projects* finds **that there is no correlation between the number of asserts and code quality, but the number of asserted object does.** This is interesting and kind of makes sense because this way empty or irrelevant assert statements are eliminated. Thus, as some further development we could consider finding a way to see if assert statements really check relevant information, and filter the irrelevant ones. But this also requires to define what is relevant information in the context of a unit test.

UT = AC / FC where: FC: function calls and AC: assert statements

| Rank | UT    |
| ---- |:-----:|
|  ++  | >4    |
|  +   | 2-4   |
|  o   | 1-2   |
|  -   | 0.5-1 |
|  --  | <0.5  |
