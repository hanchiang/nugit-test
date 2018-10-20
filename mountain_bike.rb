# Class definitions
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

class Main
  attr_accessor :visited, :input, :numRows, :numcols, :result

  def initialize()
    @visited = Hash.new # Keep track of visited nodes. Hash of hash of [r][c]
    @input = []
    @numRows = 0
    @numCols = 0
    @result = Result.new
    @neighboursDelta = Hash.new

    work()
  end

  # def calculateNeighboursDelta
  #   isOneDimInput = false
  #   if (@numRows == 1 || @numCols == 1) then
  #     isOneDimInput = true
  #   end

  #   for i in 0..@numRows-1
  #     for j in 0..@numCols-1

  #     end
  #   end
  # end

  def work()
    readFile('4x4_map.txt')

    # calculateNeighboursDelta()

    for r in 0..@numRows-1
      @visited[r] = Hash.new
      @result.saved[r] = Hash.new
    end

    #TODO: Trivial cases:
    # 1. r == 0 && c == 0
    # 1. r == 1 || c == 1

    if (@numRows == 0 && @numCols == 0) then
      puts "File is empty."
    elsif (@numRows == 1 || @numCols == 1) then
      put "rows: #{@numRows}, cols: #{numCols}"
    end

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

    result = getAnswer()
    puts result
  end

  def getCornerNeighbours(r, c)
    if r == 0 then
      if c == 0 then
        return [].push([r+1, c]).push([r, c+1]).push()
      elsif c == @numCols-1 then
        return [].push([r+1, c]).push([r, c-1])
      end
    elsif r == @numRows-1 then
      if c == 0 then
        return [].push([r-1, c]).push([r, c+1])
      elsif c == @numCols-1 then
        return [].push([r-1, c]).push([r, c-1])
      end
    end
  end

  def getEdgeNeighbours(r, c)
    if r == 0 then
      return [].push([r, c-1]).push([r+1, c]).push([r, c+1])
    elsif r == @numRows-1 then
      return [].push([r, c-1]).push([r-1, c]).push([r, c+1])
    elsif c == 0 then
      return [].push([r-1, c]).push([r, c+1]).push([r+1, c])
    elsif c == @numCols-1 then
      return [].push([r-1, c]).push([r, c-1]).push([r+1, c])
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

  # add fields to path by traversing through saved result
  def constructMemoizePath(paths, path, row, col)
    savedEntry = @result.saved[row][col]
    nextRow = savedEntry.nextRow
    nextCol = savedEntry.nextCol
    addFieldToPath(path, savedEntry.row, savedEntry.col, nextRow, nextCol)

    while (true)
      savedEntry = @result.saved[nextRow][nextCol]
      nextRow = savedEntry.nextRow
      nextCol = savedEntry.nextCol
      addFieldToPath(path, savedEntry.row, savedEntry.col, nextRow, nextCol)
      if (nextRow == nil && nextCol == nil) then
        paths.push(path)
        break
      end
    end
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
    if @result.longestPathStartNode.length == 1 then
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

Main.new