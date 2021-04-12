# Maze-Solver 
Implementation of the *jump point search* algorithm in pure Lua

## Usage
Script uses **txt** files as input and output, "**in.txt**" and "**out.txt**" respectively
Input syntax:

S\_\_xx\_\_xxx  
\_\_\_xx\_\_xx\_  
\_\_\_x\_\_x\_x\_  
xx\_\_\_xx\_\_x  
xxx\_\_\_\_\_\_\_  
\_\_\_\_\_\_xxx\_  
\_\_\_\_\_\_xxxF

where S - start point, F - end point, x - wall, _ - walkable space

## Ouput:

S\_\_xx\_\_xxx  
\*\_\_xx\_\_xx\_  
\*\*\*x\_\_x\_x\_  
xx\*\*\_xx\_\_x  
xxx\*\*\*\*\*\*\*  
\_\_\_\_\_\_xxx\*  
\_\_\_\_\_\_xxxF

where * - point of path

Run solve_maze.lua via cmd

solve_maze module returns a function solve_maze(input_file, output_file),
that can be run with different txt files as input and output.


## Aditional info
Implementation of binary heap in binary_heap.lua was taken from:

https://github.com/Yonaba/Binary-Heaps

with upadte_item(value) function only being added



