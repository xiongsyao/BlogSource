---
title: "从0开始的JS之旅（三）：DOM操作基础"
date: 2018-01-25T13:51:37+08:00
tags: ["JavaScript基础教程", "JavaScript"]
categories: ["JavaScript"]
draft: false
---

# 从0开始的JS之旅（三）
> 前面讲了一些JS语言的基本语法，但是JS运用最广泛的地方就是前端开发了，肯定免不了操纵DOM节点，这章就讲讲DOM相关的东西
## DOM
> 究竟什么是DOM呢？文档对象模型 (DOM) 是HTML和XML文档的编程接口。它提供了对文档的结构化的表述，并定义了一种方式可以使从程序中对该结构进行访问，从而改变文档的结构，样式和内容。

我们从一个最简单的实例开始:
``` HTML
<html>
    <head>
    </head>
    <body>
      <p class="cls1" id="ex1">这是一句话</p>
      <p class="cls2" id="ex2">这是一句不会出现的话</p>
      <p class="cls3" id="ex3">这是一句话</p>
      <button>点我改变页面</button>
    </body>
    <script>
        // 获取元素
        var myText1 = document.getElementById("ex1")
        console.log(myText1)
        // 插入元素
        var myBlod = document.createElement("b")
        blod_text = document.createTextNode("加粗的话")
        myBlod.appendChild(blod_text)
        document.body.appendChild(myBlod)
        // 删除元素
        var myText2 = document.getElementsByClassName("cls2")[0]
        document.body.removeChild(myText2)
        // 改变元素
        var myText3 = document.getElementById("ex3")
        myText3.innerText = "这是一句被改变的话"
        myText3.style.color = "red"
        // 动态改变
        var myButton = document.getElementsByTagName("button")[0]
        myButton.addEventListener("click", function() {
          myText1.classList.toggle("active")
        })
    </script>
    <style>
     .active {
       font-size: 1.5rem;
       color: red;
       border: 1px solid gray;
     }
    </style>
</html>
```
上面演示了一些最基本的DOM节点操作，因为DOM操作的API繁多，这里就不一一列举，具体的可以看[**MDN**](https://developer.mozilla.org/en-US/docs/Web/API/Document)。
这些DOM操作的API实际没必要去记忆，经常用的肯定会记住，为了之后的实战，这里会讲一些Canvas相关的东西。
## Canvas
> `<canvas>`是一个特殊的html标签，它允许我们使用JS在其上绘图，这里我们介绍下`canvas`的一些基本API，然后接下来，我们就可以用它做一些有趣的事情。
### 图形
创建一个`canvas`元素：
``` HTML
<canvas id="tutorial" width="150" height="150"></canvas>
```
上述代码创建了一个`id`为`tutorial`，宽高均为150px的canvas画布。
获取`canvas`对象,并且通过canvas的getContext方法获取“2d”渲染内容。
``` JS
var canvas = document.getElementById('tutorial')
var ctx = canvas.getContext('2d')
```
一个简单的实例：
``` HTML
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8"/>
    <title>Canvas tutorial</title>
  </head>
  <body>
    <canvas id="tutorial" width="350" height="350"></canvas>
    <script type="text/javascript">
      function draw(){
        var canvas = document.getElementById('tutorial');
        var ctx = canvas.getContext('2d');

        // 红色正方形
        ctx.beginPath();                   // 开始绘制
        ctx.fillStyle = 'rgb(200, 0, 0)';  // 填充颜色
        ctx.rect(10, 10, 50, 50);          // 定义图形(x, y, width, heigt), 前两个数字代表坐标，后两个代表宽高
        ctx.fill();                        // 绘制
        ctx.closePath();                   // 结束绘制
        
        // 黑色正方形
        ctx.fillStyle = "black";
        ctx.fillRect(30, 30, 50, 50);      // 快速绘制方式

        // 红色圆球
        ctx.beginPath();                   
        ctx.fillStyle = "red"; 
        ctx.arc(175, 175, 20, 0, Math.PI*2, false);  // 定义图形(x, y, radiu, start_angle, end_angle, direction)         
        ctx.fill(); 
        ctx.closePath(); 
      }
      draw();
    </script>
    <style type="text/css">
      canvas { border: 1px solid black; }
    </style>
  </body>
</html>
```
这样我们就在画布上分别绘制了两个正方形和一个圆球。
### 运动
上面我们只是创建了图形，但是怎么让图形动起来呢？一个简单的思路是：我们周期的去重绘图形，重绘的时候，去改变图形的坐标。这里，我们借助`setInterval`这个方法，这个方法创建了一个定时器。
``` HTML
function draw() {
  console.log(1)
}
setInterval(draw, 1000);
```
这样，每隔1s，就会打印1
运用到我们的`canvas`上：
``` HTML
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8"/>
    <title>Canvas tutorial</title>
  </head>
  <body>
    <canvas id="tutorial" width="350" height="350"></canvas>
    <script type="text/javascript">
      var x = 0, y = 0
      function draw(){
        var canvas = document.getElementById('tutorial');
        var ctx = canvas.getContext('2d')
        // clear
        ctx.clearRect(0,0,canvas.width,canvas.height);  
        // 红色圆球
        ctx.beginPath();                   
        ctx.fillStyle = "red"; 
        ctx.arc(175+x, 175+y, 20, 0, Math.PI*2, false);  // 定义图形(x, y, radiu, start_angle, end_angle, direction)         
        ctx.fill(); 
        ctx.closePath();
        x += 5
        y += 5 
      }
      setInterval(draw, 500);
    </script>
    <style type="text/css">
      canvas { border: 1px solid black; }
    </style>
  </body>
</html>
```
