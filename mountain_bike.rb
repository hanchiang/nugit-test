# Data structure
# 1. A Field class to store: row, column, value, next row, next column
# 2. A Path class to store: array of fields, longest path length for each node, longest path length so far
# 3. A Result class to store: hash of hash of fields of the longest path for each node, start node of longest path(s)

# Strategy
# For each node
#   Use DFS to find a list of down slope paths
#   Get the longest path. If there are more than 1 path with the same length, get the steepest path
#   For each field in longest path
#     Mark node as visited
#     Save field to avoid recomputation when visiting same node
#   Update longest path starting node
# Construct the longest path from the longest path start node


class Result
  attr_accessor :saved, :longestPathStartNode 

  def initialize()
    # Save the longest path for each node. Hash of hash of field
    @saved = Hash.new

    # start node of longest path(s)
    @longestPathStartNode = []
  end
end


class Path
  attr_accessor :length, :startVal, :endVal, :startRow, :startCol, :fields
  @longest = 0
  @longestPerNode = 0

  class << self
    attr_accessor :longest, :longestPerNode
  end

  def initialize()
    @length = 0
    @fields = []
  end
end

class Field
  attr_accessor :row, :col, :nextRow, :nextCol, :val

  def initialize(row, col, nextRow, nextCol, val)
    @row = row
    @col = col
    @nextRow = nextRow
    @nextCol = nextCol
    @val = val
  end
end

class MountainBike
  attr_accessor :visited, :input, :numRows, :numcols, :result, :isOneDimInput

  def initialize(options)
    # Keep track of whether input[i][j] has been visited. Hash of hash of boolean
    @visited = Hash.new
    @file = options.fetch(:file)
    @input = []
    @numRows = 0
    @numCols = 0
    @result = Result.new
    # deltas for N, S, E, W neighbour nodes. Hash of array of [delta row, delta col]
    @neighbourDelta = Hash.new
    @neighbourDelta['N'] = [-1, 0]
    @neighbourDelta['S'] = [1, 0]
    @neighbourDelta['E'] = [0, 1]
    @neighbourDelta['W'] = [0, -1]
  end
  
  def work()
    readFile(@file)

    for r in 0..@numRows-1
      @visited[r] = Hash.new
      @result.saved[r] = Hash.new
    end

    # No need to run program for trivial cases
    if ((@numRows != 0 && @numCols != 0) && (@numRows != 1 || @numCols != 1)) then
      row = 0
      while (row < @numRows)
        col = 0
        while (col < @numCols)
          findBestPath(row, col)
          # puts unwindPathFromNode(row, col).join('-')
          col = col + 1
        end
        row = row + 1
      end
    end
  end

  def getCornerNeighbours(r, c)
    deltaNorthRow, deltaNorthCol = @neighbourDelta['N']
    deltaSouthRow, deltaSouthCol = @neighbourDelta['S']
    deltaEastRow, deltaEastCol = @neighbourDelta['E']
    deltaWestRow, deltaWestCol = @neighbourDelta['W']

    if r == 0 then
      if c == 0 then
        return @numRows == 1 ? [].push([r + deltaEastRow, c + deltaEastCol]) : 
          @numCols == 1 ? [].push([r + deltaSouthRow, c + deltaSouthCol]) :
            [].push([r + deltaEastRow, c + deltaEastCol]).push([r + deltaSouthRow, c + deltaSouthCol])
      elsif c == @numCols-1 then
        return @numRows == 1 ? [].push([r + deltaWestRow, c + deltaWestCol]) :
          @numCols == 1 ? [].push([r + deltaSouthRow, c + deltaSouthCol]) :
            [].push([r + deltaWestRow, c + deltaWestCol]).push([r + deltaSouthRow, c + deltaSouthCol])
      end
    elsif r == @numRows-1 then
      if c == 0 then
        return @numRows == 1 ? [].push([r + deltaEastRow, c + deltaEastCol]) :
          @numCols == 1 ? [].push([r + deltaNorthRow, c + deltaNorthCol]) :
            [].push([r + deltaEastRow, c + deltaEastCol]).push([r + deltaNorthRow, c + deltaNorthCol])
      elsif c == @numCols-1 then
        return @numRows == 1 ? [].push([r + deltaWestRow, c + deltaWestCol]) :
          @numCols == 1 ? [].push([r + deltaNorthRow, c + deltaNorthCol]) :
            [].push([r + deltaWestRow, c + deltaWestCol]).push([r + deltaNorthRow, c + deltaNorthCol])
      end
    end
  end

  def getEdgeNeighbours(r, c)
    deltaNorthRow, deltaNorthCol = @neighbourDelta['N']
    deltaSouthRow, deltaSouthCol = @neighbourDelta['S']
    deltaEastRow, deltaEastCol = @neighbourDelta['E']
    deltaWestRow, deltaWestCol = @neighbourDelta['W']

    if r == 0 then
      return @numRows == 1 ? [].push([r + deltaWestRow, c + deltaWestCol]).push([r + deltaEastRow, c + deltaEastCol]) :
        [].push([r + deltaWestRow, c + deltaWestCol]).push([r + deltaSouthRow, c + deltaSouthCol])
        .push([r + deltaEastRow, c + deltaEastCol])
    elsif r == @numRows-1 then
      return @numRows == 1 ? [].push([r + deltaWestRow, c + deltaWestCol]).push([r + deltaEastRow, c + deltaEastCol]) :
        [].push([r + deltaWestRow, c + deltaWestCol]).push([r + deltaNorthRow, c + deltaNorthCol])
        .push([r + deltaEastRow, c + deltaEastCol])
    elsif c == 0 then
      return @numCols == 1 ? [].push([r + deltaNorthRow, c + deltaNorthCol]).push([r + deltaSouthRow, c + deltaSouthCol]) :
        [].push([r + deltaNorthRow, c + deltaNorthCol]).push([r + deltaEastRow, c + deltaEastCol])
        .push([r + deltaSouthRow, c + deltaSouthCol])
    elsif c == @numCols-1 then
      return @numCols == 1 ? [].push([r + deltaNorthRow, c + deltaNorthCol]).push([r + deltaSouthRow, c + deltaSouthCol]) :
        [].push([r + deltaNorthRow, c + deltaNorthCol]).push([r + deltaWestRow, c + deltaWestCol])
        .push([r + deltaSouthRow, c + deltaSouthCol])
    end
  end

  # Returns an array of array of row col, e.g. [[2, 0], [3, 1]]
  def getNeighbours(r, c)
    if (
      (r == 0 && (c == 0 || c == @numCols - 1)) ||
      (r == @numRows - 1 && (c == 0 || c == @numCols - 1))) then
      return getCornerNeighbours(r, c)
    elsif (
      (r > 0 && r < @numRows - 1 && (c == 0 || c == @numCols - 1)) ||
      (c > 0 && c < @numCols - 1 && (r == 0 || r == @numRows - 1))) then
      return getEdgeNeighbours(r, c)
    else
      return [].push([r, c-1]).push([r, c+1]).push([r-1, c]).push([r+1, c])
    end
  end

  # memoize fields in path
  def memoize(fields)
    # path of length 1 isn't worth saving
    if fields.length > 1 then
      for i in 0..fields.length-1
        field = fields[i]
        @result.saved[field.row][field.col] = field
        @visited[field.row][field.col] = true
      end
    end
  end

  # add fields to path by traversing through saved result, and add path to the list of paths for input[row][col]
  def constructMemoizePath(paths, path, row, col)
    savedEntry = @result.saved[row][col]
    nextRow = savedEntry.nextRow
    nextCol = savedEntry.nextCol
    addFieldToPath(path, savedEntry.row, savedEntry.col, nextRow, nextCol)

    while (nextRow != nil && nextCol != nil)
      savedEntry = @result.saved[nextRow][nextCol]
      nextRow = savedEntry.nextRow
      nextCol = savedEntry.nextCol
      addFieldToPath(path, savedEntry.row, savedEntry.col, nextRow, nextCol)
    end
    paths.push(path)
  end

  def addFieldToPath(path, r, c, nextR = nil, nextC = nil)
    path.fields.push(Field.new(r, c, nextR, nextC, @input[r][c]))
    path.length += 1
    if (path.length > Path.longestPerNode) then
      Path.longestPerNode = path.length
    end
  end

  # backtrack path up to A[r][c]
  def getBacktrackIndex(fields, r, c)
    for i in (fields.length-1).downto(0)
      field = fields[i]
      if (field.val == @input[r][c]) then
        return i
      end
    end
  end

  def getLongestPathPerNode(paths)
    longestPaths = paths.select { |path|
      path.length == Path.longestPerNode
    }

    if longestPaths.length == 1 then
      return longestPaths[0]
    else
      largestDescent = 0
      largestIdx = 0

      for i in 0..longestPaths.length-1
        fields = longestPaths[i].fields
        descent = fields[0].val - fields[-1].val
        if descent > largestDescent then
          largestDescent = descent
          largestIdx = i
        end
      end
      return longestPaths[largestIdx]
    end
  end

  # construct path(array integers) from node by traversing saved result
  def unwindPathFromNode(row, col)
    savedField = @result.saved[row][col]
    if (!savedField) then
      return [@input[row][col]]
    end
    nextRow = savedField.nextRow
    nextCol = savedField.nextCol
    result = [].push(savedField.val)

    while (nextRow != nil && nextCol != nil)
      savedField = @result.saved[nextRow][nextCol]
      nextRow = savedField.nextRow
      nextCol = savedField.nextCol
      result.push(savedField.val)
    end
    return result
  end

  def getAnswer()
    if (@numRows == 0 && @numCols == 0) then
      return "File is empty. Exiting..."
    elsif (@numRows == 1 && @numCols == 1) then
      return @input[0][0]
    elsif @result.longestPathStartNode.length == 1 then
      row = @result.longestPathStartNode[0].row
      col = @result.longestPathStartNode[0].col
      return unwindPathFromNode(row, col).join('-')
    else
      results = []
      largestDescent = 0
      largestIdx = 0

      @result.longestPathStartNode.each { |startNode|
        results.push(unwindPathFromNode(startNode.row, startNode.col))
      }

      # Get path with steepest descent
      for i in 0..results.length-1
        result = results[i]
        descent = result[0].to_i - result[-1].to_i
        if (descent > largestDescent) then
          largestDescent = descent
          largestIdx = i
        end
      end
      return results[largestIdx].join('-')
    end
  end

  def dfs(paths, path, row, col)
    neighbours = getNeighbours(row, col)
    selectedNeighbours = neighbours.select { |neighbour|
      @input[row][col] > @input[neighbour[0]][neighbour[1]]
    }

    # base case
    if selectedNeighbours.length == 0 then
      addFieldToPath(path, row, col)
      paths.push(path)  
    else
      # Non recursive case: retrieve from memoized path
      if (@visited[row][col]) then
        constructMemoizePath(paths, path, row, col)
      else
        # Recursively visit neighbours
        for idx in 0..selectedNeighbours.length-1
          neighbour = selectedNeighbours[idx]
          nextR, nextC = neighbour

          addFieldToPath(path, row, col, nextR, nextC)
          dfs(paths, path, nextR, nextC)

          # When returning from base case, if current neighbour is not the last neighbour of A[row][col],
          # backtrack path up to A[row][col] to reset the path from first field to A[row][col]
          if idx != selectedNeighbours.length-1 then
            fields = [] + path.fields
            length = path.length

            newFields = fields.slice(0, getBacktrackIndex(path.fields, row, col))
            path = Path.new
            path.fields = newFields
            path.length = newFields.length
          end
          
        end
      end
    end
  end

  # Find best path for a node
  def findBestPath(r, c)
    Path.longestPerNode = 0
    paths = []

    dfs(paths, Path.new, r, c)

    longestPath = getLongestPathPerNode(paths)

    # memoize longest path for each node
    memoize(longestPath.fields)

    # Calculate longest path so far
    if (Path.longestPerNode > Path.longest) then
      Path.longest = Path.longestPerNode
      @result.longestPathStartNode = [longestPath.fields[0]]
    elsif (Path.longestPerNode == Path.longest) then
      @result.longestPathStartNode.push(longestPath.fields[0])
    end
  end

  def readFile(file)
    lineNum = 1
    IO.foreach(file) { |line|
      values = line.split(' ').map{ |value| value.to_i }
      if (lineNum == 1) then
        @numRows, @numCols = values
      else
        @input.push(values)
      end
      lineNum += 1
    }
  end
end

m = MountainBike.new({file: 'map.txt'})
m.work()
result = m.getAnswer()
puts result
