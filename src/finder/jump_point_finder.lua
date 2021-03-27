local node = require 'core.node'
local grid = require 'core.grid'
local heap = require 'core.binary_heap'
local abs = math.abs
local max = math.max
local sqrt = math.sqrt
local pow = math.pow

-----------------------------------------------------------------------------
-- Heap sorting function by f value of the nodes, used for Min-Heap creation
-- 
-- @param nodeA          node that is being moved
-- @param nodeB          node that is considered to swap positions with nodeA
-- @return               nodeA.f < nodeB.f
----------------------------------------------------------------------------- 
local function comp(nodeA, nodeB)
  return nodeA.f < nodeB.f
end

-----------------------------------------------------------------------------
-- Manhattan distance
-- 
-- @param  dx            Difference in x 
-- @param  dy            Difference in y
-- @return               dx + dy
-----------------------------------------------------------------------------
local function manhattan(dx, dy)
  return dx + dy
end

-----------------------------------------------------------------------------
-- Octile distance
-- 
-- @param  dx            Difference in x 
-- @param  dy            Difference in y
-- @return               sqrt(pow(dx, 2) + pow(dy, 2))
-----------------------------------------------------------------------------
local function octile(dx, dy)
  return sqrt(pow(dx, 2) + pow(dy, 2))
end

jump_point_finder = {}

-----------------------------------------------------------------------------
-- jump_point_finder class is the implementation of Jump point search 
-- algorithm, where diagonal movement is prohibited
-- 
-- @constructor
-----------------------------------------------------------------------------
function jump_point_finder:new()
  self.__index = self
  local finder = {heuristic = manhattan}
  return setmetatable(finder, self)
end

-----------------------------------------------------------------------------
-- Finds and returns path if it exists
--
-- @param  start_x       x coordinate of start node
-- @param  start_y       y coordinate of start node
-- @param  end_x         x coordinate of end node
-- @param  end_y         y coordinate of end node
-- @param  grid          matrix representation of the maze, elements of which 
--                       are nodes
-- @returns              path, or an empty table if it does not exist
-----------------------------------------------------------------------------
function jump_point_finder:find_path(start_x, start_y, end_x, end_y, grid)
  local node
  local start_node = grid:get_node_at(start_x, start_y)
  local end_node = grid:get_node_at(end_x, end_y)

  self.grid = grid
  self.opened_nodes = heap(comp)
  self.end_node = end_node

  --[[
      set start_node g and f to 0,
      where g is a metric for distance from start
      and f = g + h, where h is a result of heuristic function
  ]]--
  start_node.g = 0
  start_node.f = 0

  self.opened_nodes:add(start_node)

  while self.opened_nodes:getSize() > 0 do
    -- pop the node with the minimum f value
    node = self.opened_nodes:pop()
    node.closed = true

    if node == end_node then
      return self:backtrace_path(node)
    end

    self:identify_successors(node)
    end
  return {} -- path was not found
end

-----------------------------------------------------------------------------
-- Runs a jump point search in the direction of each avalible neighbor,
-- adding them to the heap of opened nodes
-- 
-- @param  node          node, from which jump points are being searched for,
--                       and being added to jump_point_finder.opened_nodes 
--                       heap
-----------------------------------------------------------------------------
function jump_point_finder:identify_successors(node)
  local end_x = self.end_node.x
  local end_y = self.end_node.y
  local x = node.x
  local y = node.y
  local neighbors = self:find_neighbors(node)
  local neighbor, jump_point, jump_node, jx, jy, d, ng, i

  for i = 1, #neighbors do
    neighbor = neighbors[i]

    jump_point = self:jump(neighbor[1], neighbor[2], x, y)

    if jump_point then
      jx = jump_point[1]
      jy = jump_point[2]

      jump_node = self.grid:get_node_at(jx, jy)

      if not jump_node.closed then
        -- include distance, as parent may not be immediately adjacent
        d = octile(abs(jx - x), abs(jy - y))

        ng = node.g + d

        if not jump_node.opened or ng < jump_node.g then
          jump_node.g = ng
          jump_node.h = jump_node.h or self.heuristic(abs(jx - end_x),
                                                      abs(jy, - end_y))
          jump_node.f = jump_node.g + jump_node.h
          jump_node.parent = node

          if jump_node.opened then
            self.opened_nodes:update_item(jump_node)
          else
            jump_node.opened = true
            self.opened_nodes:add(jump_node)
          end

        end -- if not jump_node.opened or ng < jump_node.g
      end -- if not jump_node.closed
    end -- if jump_point
  end -- for i string
end

-----------------------------------------------------------------------------
-- Searchs for prunned and forced neighbors of the given node, if the node
-- has no parent then returns all available neighbors 
-- 
-- @param  node          node, for which prunned and forced neighbors are
--                       searched for
-- @return               table of prunned and forced neigbors
-----------------------------------------------------------------------------
function jump_point_finder:find_neighbors(node)
  local parent = node.parent
  local x = node.x
  local y = node.y
  local neighbors = {}
  local px, py, dx, dy, i, neighbor_node

  -- can prun some neighbours, as parent exists
  if parent then
    px = parent.x
    py = parent.y

    -- normalized direction of step
    dx = (x - px) / max(abs(x - px), 1)
    dy = (y - py) / max(abs(y - py), 1)

    if dx ~= 0 then
      if self.grid:is_walkable_at(x, y - 1) then
        table.insert(neighbors, {x, y - 1})
      end

      if self.grid:is_walkable_at(x, y + 1) then
        table.insert(neighbors, {x, y + 1})
      end

      if self.grid:is_walkable_at(x + dx, y) then
        table.insert(neighbors, {x + dx, y})
      end
    elseif dy ~= 0 then
      if self.grid:is_walkable_at(x - 1, y) then
        table.insert(neighbors, {x - 1, y})
      end

      if self.grid:is_walkable_at(x + 1, y) then
        table.insert(neighbors, {x + 1, y})
      end

      if self.grid:is_walkable_at(x, y + dy) then
        table.insert(neighbors, {x, y + dy})
      end
    end -- elseif dy
  else
    neighbor_nodes = self.grid:get_neighbors(node)

    for i = 1, #neighbor_nodes do
      neighbor_node = neighbor_nodes[i]
      table.insert(neighbors, {neighbor_node.x, neighbor_node.y})
    end
  end

  return neighbors
end

-----------------------------------------------------------------------------
-- Recursive function searching for a jump point in the direction from parent
-- to the current node
-- 
-- @param  x             x coordinate of the current node
-- @param  y             y coordinate of the current node
-- @param  px            x coordinate of the parent node
-- @param  py            y coordinate of the parent node
-- @return               nil if current node lies outside of the maze,
--                       or is a wall. {x, y} if a jump point is found,
--                       otherwise recursively goes in the direction {dx, dy}
--                       until jump point is found. 
-----------------------------------------------------------------------------
function jump_point_finder:jump(x, y, px, py)
  local dx = x - px
  local dy = y - py

  if not self.grid:is_walkable_at(x, y) then
    return nil
  end

  if self.grid:get_node_at(x, y) == self.end_node then
    return {x, y}
  end

  -- moving horizontaly check for forced neighbors in vertical direction
  if dx ~= 0 then
    if (self.grid:is_walkable_at(x, y - 1) and not self.grid:is_walkable_at(x - dx, y - 1)) or
       (self.grid:is_walkable_at(x, y + 1) and not self.grid:is_walkable_at(x - dx, y + 1)) then
      return {x, y}
    end
  -- moving verticaly check for forced neighbors in horizontal direction
  elseif dy ~= 0 then
    if (self.grid:is_walkable_at(x - 1, y) and not self.grid:is_walkable_at(x - 1, y - dy)) or
       (self.grid:is_walkable_at(x + 1, y) and not self.grid:is_walkable_at(x + 1, y - dy)) then
      return {x, y}
    end

    -- moving vertically, must check for horizontal jump points 
    if self:jump(x + 1, y, x, y) or self:jump(x - 1, y, x, y) then
      return {x, y}
    end
  end

  return self:jump(x + dx, y + dy, x, y)
end

-----------------------------------------------------------------------------
-- Backtraces the sequence of jump points, from the given node to start and
-- reverses it
-- 
-- @param  node          node to sequence is being backtraced from 
-- @return               start -> node sequence of jump points
-----------------------------------------------------------------------------
function jump_point_finder:backtrace_path(node)
  local path = {
    {
      node.x, 
      node.y
    }
  }

  while node.parent do
    node = node.parent
    table.insert(path, {node.x, node.y})
  end

  return reverse_path(path)
end

-----------------------------------------------------------------------------
-- Reverses the given table
--
-- @param  path          table to reverse
-- @return               reversed table
-----------------------------------------------------------------------------
function reverse_path(path)
  local reversed_path = {}

  for i = #path, 1, -1 do
    table.insert(reversed_path, path[i])
  end

  return reversed_path
end

return jump_point_finder
