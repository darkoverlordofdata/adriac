[indent=4]
uses GLib
uses Gee

namespace Utils

    exception Exceptions
        OutOfBounds
    //
    // Simple parsing
    //
    class StringTokenizer

        currentPosition: int = 0
        newPosition: int = -1
        maxPosition: int = 0 
        retDelims: bool = false
        str: string = "" 
        delimiters: string = ""

        construct(str:string, delimiters: string = " \t\n\r\f", retDelims:bool = false)
            this.str = str
            this.delimiters = delimiters
            this.retDelims = retDelims
            maxPosition = str.length

        def skipDelimiters(startPos:int):int
            var position = startPos
            while !retDelims && position < maxPosition
                var c = str[position]
                if !isDelimiter(c) do break
                position += 1

            return position

        def scanToken(startPos:int):int
            var position = startPos
            while position < maxPosition
                var c = str[position]
                if isDelimiter(c) do break
                position += 1

            if retDelims && (startPos == position)
                var c = str[position]
                if isDelimiter(c) do position += 1

            return position


        def isDelimiter(c:char):bool
            return delimiters.index_of_char(c) >= 0

        def hasMoreTokens():bool
            newPosition = skipDelimiters(currentPosition)
            return newPosition < maxPosition

        def nextToken():string
            if newPosition >= 0 
                currentPosition = newPosition 
            else 
                currentPosition = skipDelimiters(currentPosition)
            newPosition = -1

            if currentPosition >= maxPosition do raise new Exceptions.OutOfBounds("")
            var start = currentPosition
            currentPosition = scanToken(currentPosition)
            return str.substring(start, currentPosition-start)

        def countTokens():int
            var count = 0
            var currpos = currentPosition
            while currpos < maxPosition
                currpos = skipDelimiters(currpos)
                if currpos >= maxPosition do break
                currpos = scanToken(currpos)
                count++

            return count

        def toArray(skip:string = ""):array of string
            tokens: array of string = new array of string[0]
            while hasMoreTokens()
                var tok = nextToken()
                if skip.index_of(tok) < 0
                    tokens+= tok
            return tokens
