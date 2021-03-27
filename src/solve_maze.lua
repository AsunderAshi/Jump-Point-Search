local node = require 'core.node'
local grid = require 'core.grid'
local heap = require 'core.binary_heap'
local jump_point_finder = require 'finder.jump_point_finder'
local max = math.max
local abs = math.abs

-----------------------------------------------------------------------------
-- Reads maze from txt file, identifies start and finish points, makes
-- true-false matrix representation of the maze, where true stands for wall,
-- and false for walkable point
-- 
-- @param filename       filename to read from
-- @return               maze, start, finish
-----------------------------------------------------------------------------
local function read_maze_from_txt(filename)
  local str, row, i, symbol
  local maze = {}
  local start = {}
  local finish = {}
  local input_interpreter = {
      x = true,
      _ = false
  }
  local input = io.open(filename, 'r')

  for line in input:lines() do
    row = {}
    line:gsub('.', function(c) table.insert(row, c) end)

    for i = 1, #line do
      -- if current symbol is start - record its position, set it walkable
      if row[i] == 'S' then
        start = {x = i, y = #maze + 1}
        row[i] = false
      -- if current symbol is end - record its position, set it walkable
      elseif row[i] == 'F' then
        finish = {x = i, y = #maze + 1}
        row[i] = false
      -- otherwise check if point is walkable
      else
        symbol = row[i]
        row[i] = input_interpreter[symbol]
      end -- if string
    end -- for each line[i]
    table.insert(maze, row)
  end -- for each line

  input:close()

  return maze, start, finish
end

-----------------------------------------------------------------------------
-- Writes solved maze to the txt file, where points that belong to the path 
-- are marked with a '*' symbol
-- 
-- @param  filename      filename to write to
-- @param  answer        sequence of the jump points, representing the path
-- @param  maze          true-false matrix representing the maze
-- @param  start         {x, y} coordinates of the start point
-- @param  finish        {x, y} coordinates of the finish point 
-----------------------------------------------------------------------------
local function write_solved_maze_to_txt(filename, answer, maze, start, finish)
  local output = io.open(filename, 'w')
  local dx, dy, x, y, nx, ny, i, j
  local width = #maze[1] -- number of columns
  local height = #maze -- number of rows
  
  --[[ 
      Replenishes missing path points between jump points
      {x, y} - current point, {nx, ny} - next jump point in path,
      {dx, dy} - (x, y -> nx, ny) direction of travel
  ]]--
  for i = 1, #answer - 1 do
    x = answer[i][1]
    y = answer[i][2]
    nx = answer[i + 1][1]
    ny = answer[i + 1][2]
  
    dx = (nx - x) / max(abs(nx - x), 1)
    dy = (ny - y) / max(abs(ny - y), 1)
  
    for j = 1, max(abs(x - nx), abs(y - ny)) do
      maze[y + j * dy][x + j * dx] = '*'
    end
  end
  
  maze[start.y][start.x] = 'S'
  maze[finish.y][finish.x] = 'F'
  
  for i = 1, height do
    for j = 1, width do
      if maze[i][j] == true then
        output:write('x')
      elseif maze[i][j] == false then
        output:write('_')
      else
        output:write(maze[i][j])
      end -- if maze
    end -- for j
    output:write('\n')
  end

  output:close()
end

-----------------------------------------------------------------------------
-- Reads maze from input_file (txt), uses jump point search algorithm to find 
-- its solution, and writes solved maze to the output_file (also txt)
-- 
-- @param  input_file    filename to read from
-- @param  output_file   filename to write to
-----------------------------------------------------------------------------
function solve_maze(input_file, output_file)
  local maze, start, finish = read_maze_from_txt(input_file)
  local width = #maze[1]
  local height = #maze

  local finder = jump_point_finder:new()
  local grid = grid:new(width, height, maze)
  
  local answer = finder:find_path(start.x, start.y, finish.x, finish.y, grid)
  
  write_solved_maze_to_txt(output_file, answer, maze, start, finish)
end

solve_maze('in.txt', 'out.txt')

return solve_maze
