---
title: "[LeetCode]150:逆波兰表达式求值"
date: 2018-12-19T15:08:08+08:00
tags: ["leetcode", "stack"]
categories: ["leetcode"]
draft: false
---

> 本章代码: **[这里](https://github.com/erds8806/leetcode/tree/master/150_Evaluate_Reverse_Polish_Notation)**

## 思路

leetcode第150题： 根据逆波兰表示法，求表达式的值。(题目具体信息文章顶部的链接代码里有)

这是一道运用**栈**来求解的题。

通过分析题目意思，我们很容易想出这样的做法：

1. 遍历字符，每当遇到非操作符(即数字)时，我们将此数字入栈。
2. 当遇到操作符时(即`+` `-` `*` `/`), 我们将栈顶的两个元素出栈，并按顺序与操作符执行运算，例如，当前操作符为`/`，出栈元素为依次为n2, n1, 则n3 = n2 / n1,并将计算结果n3入栈。
3. 当遍历完输入后，栈中只剩一个最终的元素，此元素极为表达式最终的结果。

## 代码

### Go

``` Go
func evalRPN(tokens []string) int {
	operations := map[string]func(int, int) int{
		"+": func(number1, number2 int) int {return number1+number2},
		"-": func(number1, number2 int) int {return number1-number2},
		"*": func(number1, number2 int) int {return number1*number2},
		"/": func(number1, number2 int) int {return int(number1/number2)},
	}
	stack := []int{}
	for _, token := range tokens {
		if operationfunc, had := operations[token]; had {
			length := len(stack)
			number1, number2 := stack[length-2], stack[length-1]
			stack = stack[:length-2]
			number := operationfunc(number1, number2)
			stack = append(stack, number)
		} else {
			number, _ := strconv.Atoi(token)
			stack = append(stack, number)
		}
	}
	return stack[0]
}
```

## Python3.5

``` Python
class Solution:
    def evalRPN(self, tokens):
        """
        :type tokens: List[str]
        :rtype: int
        """
        stack = []
        operations = {
            "+": "ADD",
            "-": "SUB",
            "*": "MUL",
            "/": "DIV",
        }
        for token in tokens:
            if token not in operations:
                stack.append(int(token))
            else:
                operation = operations[token]
                number2, number1 = stack.pop(), stack.pop()
                if operation == "ADD":
                    number = number1 + number2
                elif operation == "SUB":
                    number = number1 - number2
                elif operation == "MUL":
                    number = number1 * number2
                else:
                    number = int(number1 / number2)
                stack.append(number)
        return stack.pop()
```

需要值得注意的是，这里python版本的解法，在执行除法操作时，是`int(number1 / number2)`，而不是`number1 // number2`，这是因为官方给出的说明里:

> Division between two integers should truncate toward zero.
 
这里的保留整数，是指简单的取数字的整数部分。在正整数除法范围内，`number1 // number2`不会出现问题，但是在异号相除时，比如`-1/2`，官方期待的答案是`0`, 但是采用`number1 // number2`会得出`1`这个答案，这里是需要注意的地方。