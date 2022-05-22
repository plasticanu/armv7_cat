---
title: "COMP2300 Assignment Design Document"
author: Zhidong Piao
email: u7139999@anu.edu.au
---

<!-- write your design document here -->
This software is a digital cat. Powered by a USB cable. The cat is displayed by the LED matrix, the top two rows are eyes, the bottom three rows are mouths. User can interact with the program using two buttons on the microbit. The left button implements "feed" function, the right button implements "touch" function. Feeding the cat improves its hunger level, touching the cat shakes it. The cat has four states stored in memory, using several records as data structure, they are: happy, hungry, touch, being fed. Every state has a correspoding LED animation/picture. The happy state and hungry state is determined by the cat's hunger level. 

The major state interchange function is implemented by two function: update_state and show_state. The update_state function reads the data stored in memory, for example, hunger level, to determine what the current state is. Then, show_state will read the result from the memory, which is just written by update_state, and show the correct LED partern. For convenience, the "being fed" state is implemented seperately because it requries some animation. To make this program running, there is a major loop contains functions, which are feed, update_state, show_state only. 

The LED patterns are implemented row by row, which means to turn on some LEDs on the same row first, then turn them off, and turn on some LEDs on the other row etc. Thus, the LED pattern will be constantly shown in a loop, because the human eyes do not catch this high frequency change. The show_state will call the function contains a LED pattern.

The interrupt handlers are bridges for changing states or values. Once a interrupt handler is called, it only writes some data to memory, for example, hunger level. There are data reader code that only exist in update_state or show_state to handle the event. 

This digital pet has several states, therefore, the two major state related function update_state and show_state are appropriate to handle the states. They can handle many states without messing the code readability and safty. Additionaly, the two functions make the program extendable, since the programmer can add many state module and write them into the two functions. 

The LED pattern implementation allows different LED patterns show together, for example, the food and the cat exist together.

The interrupt handler design makes sure the program runs safely, because they do not call other functions. Additionaly, it makes the program extendable, because the programmer can add as many event functions.

The LED animation design (dropping food) has some disadvantages because it still use a wait label to determine whether the time has past to a certain amount.




Sophistication of your design and how it meets the assignment specification. (20%, 4 marks)
Sophistication of your implementation in ARM-v7 assembly language. (50%, 10 marks)
Sophistication of analysis and evaluation of why your implementation is correct and appropriate for your design and what limitations it might have. (20%, 4 marks)
Sophistication of communication and expression. (10%, 2 marks)
