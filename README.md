# FormalLanguagesAndCompilers

## Expressions Parsing
In this branch is proposed the implementation for the lexical analyzer and the parser to parse arithmetic and boolean expressions.

### Operations Supported
The operations supported could be split into the two categories and they are: 
- Arithmetic: 
  - plus (+)
  - minus (-)
  - multiplication (*)
  - division (/)
- Boolean
  - greater than (>)
  - greater or equal than (>=)
  - smaller than (<)
  - greater or equal than (<=)
  - equality  (==)
  - inequality (!=)

### Types
The parser is able to deal with boolean and numeric types.
The numeric types are integer and floating point numbers and they are treated differently. Therefore, all arithmetic operations are implemented in such a way to make distinction among integer and floating point inputs.
To make an example, the expression ``` 4 / 3 = 1 ``` returns an integer, since the two operands are integers. On the other hand, the expression ``` 4.0 / 3 = 1.3333333... ``` since the first operand is floating point.

### Examples
Follows examples of valid expressions with their provided result and invalid expressions with their correspondent error explanation.

#### Valid Expressions
Arithmetic example:
```
  (12 * 4) - 5 = 43
  12 * 4 - 5 = 43
```
Notice that the arithmetic expressions are evaluated following the conventional precedence among the operators, therefore the absence of parenthesis in the second example doesn't change the result.

Boolean example:
```
  (4 >= 2) -> true
  !(4 < 2) -> true
  4 != 4   -> false
```
