#Maze-Solver#
Implementation of the *jump point search* algorithm in pure Lua

##Usage##
Script uses *txt* files as input and output, "in.txt" and "out.txt" respectively
Input syntax:

S__xx__xxx 
___xx__xx_ 
___x__x_x_ 
xx___xx__x 
xxx_______ 
______xxx_ 
______xxxF

where S - start point, F - end point, x - wall, _ - walkable space

Ouput:

S__xx__xxx 
*__xx__xx_ 
***x__x_x_ 
xx**_xx__x 
xxx******* 
______xxx* 
______xxxF

where * - point of path

Run solve_maze.lua via cmd

solve_maze module returns a function solve_maze(input_file, output_file),
that can be run with different txt files as input and output.


##Aditional info##
Implementation of binary heap in binary_heap.lua was taken from:

https://github.com/Yonaba/Binary-Heaps

with upadte_item(value) function only being added



