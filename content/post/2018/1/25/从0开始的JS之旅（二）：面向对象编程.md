---
title: "从0开始的JS之旅（二）：面向对象编程"
date: 2018-01-25T13:48:56+08:00
tags: ["JavaScript基础教程", "JavaScript"]
categories: ["JavaScript"]
draft: false
---

# 从0开始的JS之旅（二）
## 面向对象
### 类
> JavaScript是一种基于原型的语言，它没类的声明语句，比如C+ +或Java中用的。这有时会对习惯使用有类申明语句语言的程序员产生困扰。相反，JavaScript可用方法作类。定义一个类跟定义一个函数一样简单。在下面的例子中，我们定义了一个新类Person。
``` JS
function Person() {...}

var Person = function() {...}
```
类名采用**首字母大写**的方式，以此来与函数声明区分开。
### 对象
对象是类的实例，一般通过`new obj`的方式创建，下面演示了如何创建一个类的实例。
``` JS
function Person() {...}
var person1 = new Person();
var person2 = new Person();
```
### 构造器
构造器指在实例创建时执行的方法，类似于python的__init__方法。
``` JS
function Person() {
    console.log("init")
};

var person1 = new Person(); // -> init
```
### 属性
> 属性就是 类中包含的变量;每一个对象实例有若干个属性. 为了正确的继承，属性应该被定义在类的原型属性 (函数)中。可以使用 关键字 this调用类中的属性, this是对当前对象的引用。从外部存取(读/写)其属性的语法是: InstanceName.Property。
``` JS
function Person(name) {
    this.name = name;
    console.log(this.name);
}

var person1 = new Person('Xiong') // -> Xiong
console.log(person1.name) // -> Xiong
```
### 方法
方法指的是类中的方法
``` JS
function Person(name) {
    this.name = name;
    this.greeting = function() {
        console.log(this.name)
    }
}
var person = new Person("xiong");
person.greeting(); // -> xiong
```
### 继承
+ 构造函数继承

同其他语言的面向对象一样，JS同样支持继承，它的继承，来源于**原型链**`prototype`
``` JS
function Person(name) {
    this.name = name;
    this.greeting = function() {
        console.log(this.name)
    }
}

function Woman(name) {
    Person.call(this, name)
    this.sex = "woman"
}
```
`Woman`继承自`Person`,它具备了`Person`的`name`属性和`greeting`方法，同时，扩展自己的属性`sex`

运行下面代码
``` JS
var lucy = new Woman("lucy")
lucy.name // -> lucy
lucy.greeting(); // -> lucy
lucy.sex // -> woman
```
可以看到，`lucy`具备`Woman`从`Person`继承的方法和属性。

保持上面的代码别动，接着，我们为`Person`动态的增加一个新的方法
``` JS
Person.prototype.eat = function() {
    console.log(this.name + " is eating")
};

lucy.eat(); // -> error
```
在为`Person`新加方法后，其子类`Woman`的实例`lucy`并不具备这个方法。显然与我们预期的不一样，这里就需要用到另一种继承方式。
+ 原型链式继承
> 为了让子类继承父类的属性（也包括方法），首先需要定义一个构造函数。然后，将父类的新实例赋值给构造函数的原型。
``` JS
function Parent(){
    this.name = 'mike';
}

function Child(){
    this.age = 12;
}

Child.prototype = new Parent(); // Child继承Parent，通过原型，形成链条

var child = new Child()
child.name // -> 'mike'
child.age  // -> 12 

Parent.prototype.eat = function() {
    console.log(this.name + " is eating")
}  // 为Parent原型添加eat方法

child.eat() // -> mike is eating
```
这样，我们就实现了动态添加父类方法后，其子类的实例同时具备此方法，但是，使用原型继承主要由两个问题：字面量重写原型会中断关系，使用引用类型的原型，并且子类型还无法给超类型传递参数。所以一般情况下，我们会把构造函数与链式继承结合起来，称之为**组合继承**。
+ 组合继承

对于`构造函数继承`一节的东西，我们运用组合继承，可以完美实现想要的效果，完整代码如下：
``` JS
function Person(name) {
    this.name = name;
    this.greeting = function() {
        console.log(this.name)
    }
}

function Woman(name) {
    Person.call(this, name) // 对象冒充，给超类型传参
    this.sex = "woman"
}
Woman.prototype = Object.create(Person.prototype);  // 原型链继承

var lucy = new Woman("lucy");

Person.prototype.eat = function() {
    console.log(this.name + " is eating")
};

lucy.eat(); // -> lucy is eating
```
其中，`Woman.prototype = Object.create(Person.prototype);`这一句，大体上是等同于`Woman.prototype = Person.prototype`，但是这样写更利于多态的表现，通常在组合继承中使用此类写法。
### 多态
对于**继承**这一节，最后完整的例子中，要实现多态，例如，覆写`eat`方法，我们只需在原有的代码基础上，增加以下代码：
``` JS
Woman.prototype.eat = function() {
    Person.prototype.eat.call(this);
    console.log(this.name + "is" + this.sex)
}

lucy.eat();
// -> lucy is eating
// -> lucy is woman
```
JS的面向对象其实是非常复杂的，这里只介绍了最基本的用法，另外，借助es6的`class`和`extend`，我们其实可以写出更优雅的代码，这一块会在之后的es6专题中讲到。