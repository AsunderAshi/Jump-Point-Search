local node = require 'core.node'

local grid = {}

-----------------------------------------------------------------------------
-- Grid class is an encapsulation of the layout of the nodes
--
-- @constructor
-- @param  width         number of columns of the given matrix
-- @param  height        number of rows of the given matrix
-- @param  matrix        matrix with true-false elements, where
--                       true represents a wall, and false is for
--                       a walkable space
-----------------------------------------------------------------------------
function grid:new(width, height, matrix)
  local newMatrix = {
    width = width, 
    height = height, 
    matrix = matrix,
		nodes =  self.build_nodes(width, height, matrix)
	}
  self.__index = self
  return setmetatable(newMatrix, self)
end

-----------------------------------------------------------------------------
-- build_nodes returns a node-matrix
-- 
-- @param  width         number of columns of the given matrix
-- @param  height        number of rows of the given matrix
-- @param  matrix        a true-false matrix, representing the walkable 
--                       status of the nodes
-- @returns              matrix of nodes
-----------------------------------------------------------------------------
function grid.build_nodes(width, height, matrix)
  local nodes = {}
  local i, j

  for i = 1, height do
	  nodes[i] = {}
	  for j = 1, width do
	    nodes[i][j] = node:new(j, i)
	  end 
  end

  if not matrix then
		return nodes
  end

  for i = 1, height do
		for j = 1, width do
	  	if matrix[i][j] then
				nodes[i][j].walkable = false
      end
    end
  end

  return nodes
end

-----------------------------------------------------------------------------
-- Gets the node at the given position
--
-- @param  x             x coordinate of the node to look for
-- @param  y             y coordinate of the node to look for
-- @return               node at the given position
-----------------------------------------------------------------------------
function grid:get_node_at(x, y)
  return self.nodes[y][x]
end

-----------------------------------------------------------------------------
-- Checks if node at the given coordinates if walkable
--
-- @param  x             x coordinate of the node to look for
-- @param  y             y coordinate of the node to look for
-- @return               true if the node is inside the grid and is walkable,
--                       returns false otherwise
-----------------------------------------------------------------------------
function grid:is_walkable_at(x, y)
  return self:is_inside(x, y) and self.nodes[y][x].walkable
end

-----------------------------------------------------------------------------
-- Checks if grid has a node with the given coordinates
--
-- @param  x             x coordinate of the node to look for
-- @param  y             y coordinate of the node to look for
-- @return               true if the node is inside the grid, false otherwise
-----------------------------------------------------------------------------
function grid:is_inside(x, y)
  return (x > 0 and x <= self.width) and (y > 0 and y <= self.height)
end

-----------------------------------------------------------------------------
-- Returns adjacent nodes to the given one
--
-- @param  node          node, neighbors of which are being searched for
-- @return               table of adjaent nodes
-----------------------------------------------------------------------------
function grid:get_neighbors(node)
  local neighbors = {}
  local x = node.x
  local y = node.y

  -- ↑
  if (self:is_walkable_at(x, y - 1)) then
		table.insert(neighbors, self.nodes[y - 1][x])
  end

  -- ↓
  if (self:is_walkable_at(x, y + 1)) then
  	table.insert(neighbors, self.nodes[y + 1][x])
  end

  -- ←
  if (self:is_walkable_at(x - 1, y)) then
		table.insert(neighbors, self.nodes[y][x - 1])
  end

  -- →
  if (self:is_walkable_at(x + 1, y)) then
  	table.insert(neighbors, self.nodes[y][x + 1])
  end

  return neighbors
end

return grid
