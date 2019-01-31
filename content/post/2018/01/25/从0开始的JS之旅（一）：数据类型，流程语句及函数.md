---
title: "从0开始的JS之旅（一）：数据类型，流程语句及函数"
date: 2018-01-25T13:39:21+08:00
tags: ["JavaScript基础教程", "JavaScript"]
categories: ["JavaScript"]
draft: false
---

# 从0开始的JS之旅（一）
> 半年多之前学的JS，结果后来一直在写python，现在趁着有些空闲时间，准备重新学习一遍JS，故记录下来，方便自己以后回顾，同时希望能对别人有所帮助

## 数据类型
类型 | 描述 | 示例
----- | ----- | ------
String| 字符串，一段文本。  | 'hello world'
Number| 数字，不需要引号包裹 | 666
Boolean | 布尔型，代表是或否 | True/False
Null | 代表空， 仅有一种表示方式，即null | null
Undefined | 未赋值的量 | undefined
Array | 数组 | (1, "wow", 0)
Symbol | es6引入的新数据类型，类似于function | [看这里](https://developer.mozilla.org/en-US/docs/Glossary/Symbol)

## 基本数据类型的操作
### Number 数字
+ `toSting(len)` 将数字转化为指定长度的字符串
+ `toFixed(len)` 将小数转化为小数点后指定位数的数字
+ `toPrecision(len)` 将数字转化为指定精度的数字
+ `valueOf()` 返回数字的原始数值

### String 字符串
+ `length` 返回字符串的字符数目
``` JS
var txt = "yes i do"
console.log(txt.length) // -> 8
```
+ `charAt(index)` 返回指定位置的字符串
+ `indexOf(char)` 返回指定字符的位置
+ `lastIndexOf(char)` 从后向前检索指定字符的位置
+ `concat(stringX, stringY, ...)` 连接两个或多个字符串
+ `slice(start, end)` 返回指定位置间的字符串
+ `split(string, num)` 返回按string分割最多为num的字符串组成的数组
``` JS
var txt = "yes i do"
console.log(txt.split(" ", 2)) // -> ["yes", "i"]
```

### Array 数组
+ `length` 返回数组长度
+ `concat()` 同String
+ `join(String)` 通过sting分隔，将数组元素合为一个String
+ `pop()` 删除并返回数组最后一个元素
+ `push()` 向数组末尾添加一个或多个元素，并返回数组长度
+ `reverse()` 反转数组中元素的顺序
+ `shift()` 删除并返回数组的第一个元素
+ `unshift(item1, item2, ...)` 向数组开头添加一个或多个元素，并返回长度
+ `slice(start, end)` 同String
+ `splice(index, num, item1, item2...)` 删除num个index开始的元素，并向数组添加新元素, 返回被删除的元素
``` JS
var arr = ["hello", "my", "fresh", "world"]
arr.splice(1,2,"your", "old") // -> ["my", "fresh"]
arr // -> ["hello", "your", "old", "world"]
```
+ `sort(sortby)` 将数组按sortby规则排序，若sortby为空，则默认按从小到大排序
``` JS
var arr = ["10","50","40","11","1000","1"]
arr.sort(function(a, b) {
    return a-b
}) // -> ["1", "10", "11", "40", "50", "1000"]
```

## 流程语句
### 赋值
``` JS
var hello = "world"
```
### 条件
> if ... else..
``` JS
if (9>6) {
console.log("9大于6")
} else {
console.log("9小于6")
}
```
> swith
``` JS
var age = 18;
switch (age) {
case age<18:
    console.log("未成年人")
    break;
case age>=18:
    console.log("成年人")
    break;
default:
    console.log("格式错误")
}
```
> 三元运算
``` JS
var age = 18;
age < 18 ? console.log("未成年"):console.log("成年")
```

### 循环
> for循环
``` JS
for (initializer; exit-condition; final-expression) {
    // run code
}
```
``` JS
// 计算1-100的和
var total = 0;
for (var i = 0; i<101, i++) {
    total += i;
}

// 计算1-100内的偶数和, 用coutinue跳过单次循环
var total = 0;
for (var i = 0; i<101, i++>) {
    if (i%2) {
        coutinue;
    }
    total += i;
}

// 计算给定范围内的前10个数的和，用break结束循环
var total = 0;
var range = 5806;
for (var i = 0, i<range, i++) {
    if (i>10) {
        break;
    }
    total += i;
}
```
> while循环
``` JS
initializer
while (exit-condition) {
// code to run
final-expression
}
```
``` JS
// 计算1-100内数的和
var i = 1;
var total = 0;
while (i <= 100) {
    total += i;
    i++;
}
```

## 函数
> 定义函数的N种方法
``` JS
// 直接声明
function print(word) {
    console.log(word)
}
print("hello world"); // ->  hello world

// 匿名函数,可将其分配给变量
var Myfunc = function() {
    console.log("hello world")
};
Myfunc(); // -> hello world

// 使用Function()构造函数
var print = new Function("word", "console.log(word)");
print("hi"); // -> hi

// 立即执行函数(IIFE),会在函数申明后立即执行
// IIFE有很多有趣的用法，后面会介绍到
(function(word) {
    console.log(word)
}("hello world")); // -> hello world
```
