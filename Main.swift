import Glibc
import Foundation

class Board
{
    //Board is an array of arrays
    //Each array within the array is a row

    var board = [[Tile]]()

    init(rows: Int, cols: Int, mines: Int)
    {
        //Add each row
        for y in 0...(rows - 1)
        {
            addRow()
            //print("newrow", y)
            //Add each tile in each row
            for index in 0...(cols - 1)
            {
                board[y].append(addTile())
                //print(x)
            }
        }

        //print(board.count, board[0].count)

        //Pretty sure this is unnecessary, but it will stay for now
        /*
        if(rows > 8)
        {
            for index in (rows - 8)...rows
            {
                addRow()
                //rows probably need to be populated
            }
        }

        if(cols > 8)
        {
            for index in (cols - 8)...cols
            {
                addCol()
            }
        }
        */

        initializeTiles()
    }

    //Create new array of tiles, and add it to the board
    func addRow()
    {
        let row = [Tile]()
        board.append(row)
    }

    /*This is probably unnecessary, but it stays for now
    func addCol()
    {
        for index in 0...(board.count)
        {
            addTile(row: index)
        }
    }
    */

    //Add a new tile to the row specified
    func addTile() -> Tile
    {
        let x = Tile()
        return x
    }

    func createTile() -> Tile
    {
        let x = Tile()
        return x
    }

    //Before this method is called, the board is filled with rows,
    //But the rows have no tiles in them.
    //This method fills the rows with tiles
    func initializeTiles()
    {
        let rows = board.count
        let cols = board[0].count - 1
        for y in 0...(rows - 1)
        {
            //print("Y: ", y)
            //print(cols)
            for x in 0...(cols)
            {
                //print("X: ", x)
                board[y][x] = createTile()
            }
        }
    }

    func selectMineLocations(maxY: Int, maxX: Int, startY: Int, startX: Int, numMines: Int)
    {
        srand(UInt32(Date().timeIntervalSince1970))
        //these two lines are in the java version, but I am pretty sure that arc4random_uniform
        //does this automatically, so I don't think they are needed
        //maxX = maxX - 1
        //maxY = maxY - 1

        //Arrays storing the coordinates of the starting tile and each mine
        //Checks this to make sure a mine isn't placed where it isn't supposed to be

        var unusableY = [Int]()
        var unusableX = [Int]()

        //First tile the player chose is added
        unusableY.append(startY)
        unusableX.append(startX)

        //All tiles around the initial tile are added
        //Checks to make sure each of the 8 border tiles do in fact exist
        //(In case the user picked an edge)
        if(startY > 0 && startX > 0)
        {
            unusableX.append(startX - 1);
            unusableY.append(startY - 1);
        }
        if(startY > 0)
        {
            unusableX.append(startX);
            unusableY.append(startY - 1);
        }
        if(startX < maxX && startY > 0)
        {
            unusableX.append(startX + 1);
            unusableY.append(startY - 1);
        }
        if(startX > 0)
        {
            unusableX.append(startX - 1);
            unusableY.append(startY);
        }
        if(startX < maxX)
        {
            unusableX.append(startX + 1);
            unusableY.append(startY);
        }
        if(startX > 0 && startY < maxY)
        {
            unusableX.append(startX - 1);
            unusableY.append(startY + 1);
        }
        if(startY < maxY)
        {
            unusableX.append(startX);
            unusableY.append(startY + 1);
        }
        if(startX < maxX && startY < maxY)
        {
            unusableX.append(startX + 1);
            unusableY.append(startY + 1);
        }

        //print("Made it to mine picking")
        for index in 0...(numMines - 1)
        {
            var x = Int(random() % maxX)
            //print("Try", x)
            var y = Int(random() % maxY)
            //print("Try", y)

            while(notUsable(unusableY: unusableY, unusableX: unusableX, x: x, y: y) || board[y][x].getMine())
            {
                x = Int(random() % maxX)
                y = Int(random() % maxY)
            }
            //print("X = ", x)
            //print("Y = ", y)

            board[y][x].makeMine();
            //print(x, y, "has been made a mine")

            //if need be, this is a good place for to check and see where that new mine went with
            //print commands
        }
    }

    private func notUsable(unusableY: [Int], unusableX: [Int], x: Int, y: Int) -> Bool
    {
        for index in 0...(unusableX.count - 1)
        {
            if(unusableX[index] == x && unusableY[index] == y)
            {
                return true
            }
        }

        return false
    }

    func checkIfMine(x: Int, y: Int) -> Bool
    {
        if(board[y][x].getMine())
        {
            return true
        }
        else
        {
            return false
        }
    }

    func setState(x: Int, y: Int, state: Int)
    {
        board[y][x].setState(newState: state)
    }

    func getState(x: Int, y: Int) -> Int
    {
        return board[y][x].getState()
    }

    func getNum(x: Int, y: Int) -> Int
    {
        return board[y][x].getNum()
    }

    //todo: create methods for setting the numbers, and for calculating the numbers

    //Gives each tile the number of mines surrounding it
    func setBoardNums()
    {
        //print("Into the num function")
        /*
            Note for upper bound of the for loops.
            This is supposed to be the count along the y axis,
            I have no idea how board.count will react, since it
            is a 2d array, and that method was designed with a 1d
            array in mind. Hopefully it works...

            update: I'm pretty sure this is right
        */
        /*
            Nums for each tile with 8 tiles surrounding it
            loops through each tile not on an edge, outsources the counting of the
            surrounding mines, and then sets the tile number to the outsourced number
        */
        for y in 1...(board.count - 2) //board.count - 1 would take us to the corner, so we subtract 1 more
        {
            for x in 1...(board[0].count - 2)
            {
                let a = calculateNumsInner(y: y, x: x)
                board[y][x].setNum(n: a)
            }
        }
        //print("Got inner nums")

        //nums for upper row (not corners)
        for x in 1...(board[0].count - 2)
        {
            let a = calculateNumsTop(x: x)
            board[0][x].setNum(n: a)
        }
        //print("Got upper row")

        //nums for lower row (not corners)
        for x in 1...(board[0].count - 2)
        {
            let a = calculateNumsBottom(x: x)
            //print("Calculated value of", x)
            board[board.count - 1][x].setNum(n: a)
            //print(x, "set")
        }
        //print("Got lower row")

        //nums for left side (not corners)
        for y in 1...(board.count - 2)
        {
            let a = calculateNumsLeft(y: y)
            board[y][0].setNum(n: a)
        }
        //print("got left side")

        //nums on right side (not corners)
        for y in 1...(board.count - 2)
        {
            let a = calculateNumsRight(y: y)
            board[y][board[0].count - 1].setNum(n: a);
        }
        //print("Got right side")

        //nums for corners
        setNumsForCorners()
        //print("Got corners")
    }

    func setNumsForCorners()
    {
        var upperLeft = 0
        var upperRight = 0
        var lowerLeft = 0
        var lowerRight = 0

        //checks each tile bordering the upper left corner tile,
        //adds one if it is a mine
        if(board[0][1].getMine())
        {
            upperLeft = upperLeft + 1
        }
        if(board[1][0].getMine())
        {
            upperLeft = upperLeft + 1
        }
        if(board[1][1].getMine())
        {
            upperLeft = upperLeft + 1
        }
        board[0][0].setNum(n: upperLeft)

        //upper right
        if(board[0][board[0].count - 2].getMine())
        {
            upperRight = upperRight + 1
        }
        if(board[1][board[0].count - 2].getMine())
        {
            upperRight = upperRight + 1
        }
        if(board[1][board[0].count - 1].getMine())
        {
            upperRight = upperRight + 1
        }
        board[0][board[0].count - 1].setNum(n: upperRight)

        //lower left
        if(board[board.count - 2][0].getMine())
        {
            lowerLeft = lowerLeft + 1
        }
        if(board[board.count - 2][1].getMine())
        {
            lowerLeft = lowerLeft + 1
        }
        if(board[board.count - 1][1].getMine())
        {
            lowerLeft = lowerLeft + 1
        }
        board[board.count - 1][0].setNum(n: lowerLeft)

        //lower right
        if(board[board.count - 2][board[0].count - 2].getMine())
        {
            lowerRight = lowerRight + 1
        }
        if(board[board.count - 2][board[0].count - 1].getMine())
        {
            lowerRight = lowerRight + 1
        }
        if(board[board.count - 1][board[0].count - 2].getMine())
        {
            lowerRight = lowerRight + 1
        }
        board[board.count - 1][board[0].count - 1].setNum(n: lowerRight)
    }

    private func calculateNumsRight(y: Int) -> Int
    {
        var numMines = 0

        if(board[y - 1][board[0].count - 2].getMine())
        {
            numMines = numMines + 1
        }
        if(board[y - 1][board[0].count - 1].getMine())
        {
            numMines = numMines + 1
        }
        if(board[y][board[0].count - 2].getMine())
        {
            numMines = numMines + 1
        }
        if(board[y + 1][board[0].count - 2].getMine())
        {
            numMines = numMines + 1
        }
        if(board[y + 1][board[0].count - 1].getMine())
        {
            numMines = numMines + 1
        }

        return numMines
    }

    private func calculateNumsLeft(y: Int) -> Int
    {
        var numMines = 0

        if(board[y - 1][0].getMine())
        {
            numMines = numMines + 1
        }
        if(board[y - 1][1].getMine())
        {
            numMines = numMines + 1
        }
        if(board[y][1].getMine())
        {
            numMines = numMines + 1
        }
        if(board[y + 1][0].getMine())
        {
            numMines = numMines + 1
        }
        if(board[y + 1][1].getMine())
        {
            numMines = numMines + 1
        }

        return numMines
    }

    private func calculateNumsBottom(x: Int) -> Int
    {
        var numMines = 0
        let y = board.count - 1
        //print("There are", y,"tiles in the row")

        if(board[y - 1][x - 1].getMine())
        {
            //print("Enter upper left")
            numMines = numMines + 1
            //print("Upper left set")
        }
        if(board[y - 1][x].getMine())
        {
            //print("Enter upper middle")
            numMines = numMines + 1
            //print("Upper middle set")
        }
        if(board[y - 1][x + 1].getMine())
        {
            //print("Enter upper right")
            numMines = numMines + 1
            //print("Upper right set")
        }
        if(board[y][x - 1].getMine())
        {
            //print("Enter left")
            numMines = numMines + 1
            //print("Left set")
        }
        if(board[y][x + 1].getMine())
        {
            //print("Enter right")
            numMines = numMines + 1
            //print("Right set")
        }

        return numMines
    }

    private func calculateNumsTop(x: Int) -> Int
    {
        var numMines = 0

        if(board[0][x - 1].getMine())
        {
            numMines = numMines + 1
        }
        if(board[0][x + 1].getMine())
        {
            numMines = numMines + 1
        }
        if(board[1][x - 1].getMine())
        {
            numMines = numMines + 1
        }
        if(board[1][x].getMine())
        {
            numMines = numMines + 1
        }
        if(board[1][x + 1].getMine())
        {
            numMines = numMines + 1
        }

        return numMines
    }

    private func calculateNumsInner(y: Int, x: Int) -> Int
    {
        var numMines = 0

        if(board[y - 1][x - 1].getMine())
        {
            numMines = numMines + 1
        }
        if(board[y - 1][x].getMine())
        {
            numMines = numMines + 1
        }
        if(board[y - 1][x + 1].getMine())
        {
            numMines = numMines + 1
        }
        if(board[y][x - 1].getMine())
        {
            numMines = numMines + 1
        }
        if(board[y][x + 1].getMine())
        {
            numMines = numMines + 1
        }
        if(board[y + 1][x - 1].getMine())
        {
            numMines = numMines + 1
        }
        if(board[y + 1][x].getMine())
        {
            numMines = numMines + 1
        }
        if(board[y + 1][x + 1].getMine())
        {
            numMines = numMines + 1
        }

        return numMines
    }

    //methods migrating here from the main class
    //could probably use some editing, but too lazy
    func printBoard(minesLeft: Int)
    {
        print("Mines left: ", minesLeft, "\n")
        print("   0 1 2 3 4 5 6 7\n") //upper reference for player

        //this loop creates each row
        for y in 0...7
        {
            print(y, terminator: "  ") //left reference for player, terminator prevents newline

            //this loop creates each character in the row
            for x in 0...7
            {
                //if tile untouched
                if(getState(x: x, y: y) == 0)
                {
                    print("\u{001B}[0;31mX", terminator: " ") //red X
                }
                //if tile flagged
                else if(getState(x: x, y: y) == 1)
                {
                    print("\u{001B}[0;32mf", terminator: " ") //green f
                }
                //If tile ?ed
                else if(getState(x: x, y: y) == 2)
                {
                    print("\u{001B}[0;35m?", terminator: " "); //purple ?
                }
                //If tile cleared
                else
                {
                    if(getNum(x: x, y: y) != 0)
                    {
                        let coloredNum = "\u{001B}[0;34m" + String(getNum(x: x, y: y)) //blue num
                        print(coloredNum, terminator: " ")
                    }
                    else
                    {
                        print("\u{001B}[0;37mC", terminator: " ") //prints C, resets color back to white
                    }
                }
            }
            print("\u{001B}[0;37m ", y) //right reference for player
        }
        print("\n   0 1 2 3 4 5 6 7") //lower reference for player
    }

    func printFinalBoard()
    {
        print("   0 1 2 3 4 5 6 7\n") //upper reference for player

        //this loop creates each row
        for y in 0...7
        {
            print(y, terminator: "  ") //left reference for player, terminator prevents newline

            //this loop creates each character in the row
            for x in 0...7
            {
                //if tile is a mine
                if(board[y][x].getMine())
                {
                    print("\u{001B}[0;31mM", terminator: " ") //red m
                }
                //if tile is a number
                else if(getNum(x: x, y: y) != 0)
                {
                    let coloredNum = "\u{001B}[0;34m" + String(getNum(x: x, y: y)) //blue num
                    print(coloredNum, terminator: " ")
                }
                else
                {
                    print("\u{001B}[0;37mC", terminator: " ") //prints C, resets color back to white
                }
            }
            print("\u{001B}[0;37m ", y) //right reference for player
        }
        print("\n   0 1 2 3 4 5 6 7") //lower reference for player
    }

    func playerWon() -> Bool
    {
        var theAnswer = true

        //loop through all the tiles
        for y in 0...7
        {
            for x in 0...7
            {
                //if there is a non mine that isn't cleared
                if(!checkIfMine(x: x, y: y) && getState(x: x, y: y) != 3)
                {
                    theAnswer = false
                }
            }
        }

        if(theAnswer)
        {
            printFinalBoard() //This doesn't make sense to me, but the compiler yelled at me unless I did this: update: who knows now
        }

        return theAnswer
    }

    func getRequestedState(x: Int, y: Int) -> Int
    {
        let currentState = getState(x: x, y: y)
        if(currentState == 0)
        {
            print("Would you like to\n1. Put a flag here\n2. Put a question mark here\n3. Clear this tile\n4. Cancel selecting this tile\nEnter the  number that  corresponds with the option you want.")

            let input = readLine()
            let req = Int(input!)!
            while req < 1 || req > 4
            {
                print("Invalid response. Enter a number between 1 and 4")
                let input = readLine()
                let req = Int(input!)!
            }

            return req
        }
        else if(currentState == 1)
        {
            print("Would you like to\n1. Remove the flag here\n2. Put a question mark here\n3. Cancel selecting this tile")

            var input = readLine()
            var req = Int(input!)!
            while req < 1 || req > 3
            {
                print("Invalid response. Enter a number between 1 and 3")
                input = readLine()
                req = Int(input!)!
            }
            if(req == 1)
            {
                return 0
            }
            else if(req == 3)
            {
                return 4
            }
            else
            {
                return req
            }
        }
        else if(currentState == 2)
        {
            print("Would you like to\n1. Put a flag here\n2. Remove the question mark here\n3. Clear this tile\n4. Cancel selecting this tile")

            let input = readLine()
            let req = Int(input!)!
            while req < 1 || req > 4
            {
                print("Invalid response. Enter a number between 1 and 4")
                let input = readLine()
                let req = Int(input!)!
            }

            //Removing the q mark, so we want to set the tile back to 0
            if(req == 2)
            {
                return 0
            }
            else
            {
                return req
            }
        }
        else
        {
            return 5
        }
    }

    func clearSurroundingTiles(x: Int, y: Int)
    {
        if(y > 0 && x > 0)
        {
            handleTileClearing(x: x - 1, y: y - 1);
        }
        if(y > 0)
        {
            handleTileClearing(x: x, y: y - 1);
        }
        if(x < 7 && y > 0)
        {
            handleTileClearing(x: x + 1, y: y - 1);
        }
        if(x > 0)
        {
            handleTileClearing(x: x - 1, y: y);
        }
        if(x < 7)
        {
            handleTileClearing(x: x + 1, y: y);
        }
        if(x > 0 && y < 7)
        {
            handleTileClearing(x: x - 1, y: y + 1);
        }
        if(y < 7)
        {
            handleTileClearing(x: x, y: y + 1);
        }
        if(x < 7 && y < 7)
        {
            handleTileClearing(x: x + 1, y: y + 1);
        }
    }

    func handleTileClearing(x: Int, y: Int)
    {
        if(getState(x: x, y: y) == 0)
        {
            setState(x: x, y: y, state: 3)
            if(getNum(x: x, y: y) == 0)
            {
                clearSurroundingTiles(x: x, y: y)
            }
        }
    }

}



class Tile
{
    //0 is untouched, 1 is flagged, 2 is question marked, 3 is exposed
    var state = 0

    //is or isn't a mine
    var mine = false

    //number of mines touching tile
    var num = 0

    func getState() -> Int
    {
        return state
    }

    func setState(newState: Int)
    {
        state = newState
    }

    func getMine() -> Bool
    {
        return mine
    }

    func makeMine()
    {
        mine = true
    }

    func getNum() -> Int
    {
        return num
    }

    func setNum(n: Int)
    {
        num = n
    }
}


var theBoard = Board(rows: 8, cols: 8, mines: 10)

//selecting first tile
theBoard.printBoard(minesLeft: 10)

print("Select the first tile.\nX:")
var input = readLine() //get input as string optional
//unwrap the string, cast it to an Int, and save it to x
var x = Int(input!)! //This probably works, but this might be a good place to look for bugs later (and other places like this)
while x < 0 || x > 7
{
    print("Invalid response! Enter a number between 0 and 7")
    input = readLine()
    x = Int(input!)!
}

print("Y:")
input = readLine()
var y = Int(input!)!
while y < 0 || y > 7
{
    print("Invalid response! Enter a number between 0 and 7")
    input = readLine()
    y = Int(input!)!
}

//Setting up the board
//print("Made it to setup")
theBoard.selectMineLocations(maxY: 8, maxX: 8, startY: y, startX: x, numMines: 10)
//print("Mines picked")
theBoard.setBoardNums()
//print("Nums set")
theBoard.setState(x: x, y: y, state: 3)
//print("State for first tile set")
theBoard.clearSurroundingTiles(x: x, y: y)
//print("Surrounding tiles cleared")

var minesLeft = 10

//loops until game over, or won
while 1 == 1
{
    theBoard.printBoard(minesLeft: minesLeft)
    //Get the inputted tile
    print("Select a tile\nX:")
    input = readLine()
    x = Int(input!)!
    while x < 0 || x > 7
    {
        print("Invalid response! Enter a number between 0 and 7")
        input = readLine()
        x = Int(input!)!
    }

    print("Y:")
    input = readLine()
    y = Int(input!)!
    while y < 0 || y > 7
    {
        print("Invalid response! Enter a number between 0 and 7")
        input = readLine()
        y = Int(input!)!
    }

    //find the state the requested tile is in
    var state = theBoard.getRequestedState(x: x, y: y)

    //respond by either putting/clearing a/the flag or question mark there,
    //clearing the tile, or killing the player

    //you already did that you dummie
    if(state == 5)
    {
        print("That tile is already cleared")
    }
    //player cancelled selecting this tile
    else if(state == 4)
    {
        print("Tile selection cancelled")
    }
    //player tried clearing the tile
    else if(state == 3)
    {
        //see if they dead
        if(theBoard.checkIfMine(x: x, y: y))
        {
            print("Game Over. You died.")
            theBoard.printFinalBoard()
            break
        }
        else
        {
            theBoard.setState(x: x, y: y, state: 3)

            //see if they won
            if(theBoard.playerWon())
            {
                print("Congrats! You won without dying!")
                break
            }

            if(theBoard.getNum(x: x, y: y) == 0)
            {
                theBoard.clearSurroundingTiles(x: x, y: y)
            }
        }
    }
    //put a q mark there
    else if(state == 2)
    {
        theBoard.setState(x: x, y: y, state: 2)
    }
    //put a flag there
    else if(state == 1)
    {
        theBoard.setState(x: x, y: y, state: 1)
        minesLeft = minesLeft - 1
    }
    //resetting the tile to neutral
    else if(state == 0)
    {
        if(theBoard.getState(x: x, y: y) == 1)
        {
            minesLeft = minesLeft + 1
        }
        theBoard.setState(x: x, y: y, state: 0)
    }
}
