module.exports = class StringTokenizer

    currentPosition: 0
    newPosition: -1
    maxPosition: 0 
    retDelims: false
    str: '' 
    delimiters: '' 

    constructor:(@str, @delimiters = " \t\n\r\f", @retDelims = false) ->
        @maxPosition = @str.length

    skipDelimiters:(startPos) ->
        position = startPos
        while !@retDelims && position < @maxPosition
            c = @str[position]
            if !@isDelimiter(c) then break
            position += 1

        return position

    scanToken:(startPos) ->
        position = startPos
        while position < @maxPosition
            c = @str[position]
            if @isDelimiter(c) then break
            position += 1

        if @retDelims && (startPos is position)
            c = @str[position]
            if @isDelimiter(c) then position += 1

        return position


    isDelimiter:(c) ->
        return @delimiters.indexOf(c) >= 0

    hasMoreTokens:() ->
        newPosition = @skipDelimiters(@currentPosition)
        return newPosition < @maxPosition

    nextToken:() ->
        @currentPosition = if @newPosition >= 0 then @newPosition else @skipDelimiters(@currentPosition)

        @newPosition = -1

        if @currentPosition >= @maxPosition then throw "OutOfBounds"
        start = @currentPosition
        @currentPosition = @scanToken(@currentPosition)
        return @str.substring(start, @currentPosition)

    countTokens:() ->
        count = 0
        currpos = @currentPosition
        while currpos < @maxPosition
            currpos = @skipDelimiters(currpos)
            if currpos >= @maxPosition then break
            currpos = @scanToken(currpos)
            count++

        return count

    toArray:(skip = "") ->
        tokens = []
        while @hasMoreTokens()
            tok = @nextToken()
            if skip.indexOf(tok) < 0
                tokens.push tok
        return tokens
