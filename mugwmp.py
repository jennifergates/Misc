# Courtesy of People's Computer company
# MUGWMP
# *** Converted to RSTS/E By David AHL, DIGITAL
# *** Converted to Python by Jennifer Gates, The couch
#

# https://yohan.es/swbasic/ for understanding BASIC
# REM Dont' need RANDOMIZE on his site
# Program listing
# 10 DIM P(4,2)  
# 240 GOSUB 1000
# 250 T=0
# 260 T=T+1
# 270 PRINT
# 280 PRINT
# 290 PRINT "TURN NO "T;". WHAT IS YOUR GUESS?";
# 300 INPUT M,N
# 310 FOR I=1 TO 4
# 320 IF P(I,1)=-1 THEN 400
# 330 IF P(I,1)<>M THEN 380
# 340 IF P(I,2)<>N THEN 380
# 350 P(I,1)=-1
# 360 PRINT "YOU HAVE FOUND MUGWUMP "; I
# 370 GOTO 400
# 380 D=SQR((P(I,1)-M)^2+(P(I,2)-N)^2)
# 390 PRINT "You are "INT(D*10)/10 " Units from MUGWUMP " I
# 400 NEXT I
# 410 FOR J=1 TO 4
# 420 IF P(J,1)<>-1 THEN 470
# 430 NEXT J
# 440 PRINT
# 450 PRINT "YOU GOT THEM ALL IN "; T ; "TURNS!"
# 460 GOTO 580
# 470 IF T<10 THEN 260
# 490 PRINT "SORRY, THAT's 10 tries. HEre is where they are hiding"
# 540 FOR I=1 TO 4
# 550 IF P(I,1)=-1 THEN 570
# 560 PRINT "MUGWUMP ";I; "IS AT ("; P(I,1) ;","P(I,2) ;")"
# 570 NEXT I
# 580 PRINT
# 600 PRINT "THAT WAS FUN! LET's PLAY AGAIN..."
# 610 PRINT "FOUR MORE MUGWUMPS ARE NOW in Hiding."
# 630 GOTO 240
# 1000 FOR J=1 TO 2
# 1010 FOR I=1 TO 4
# 1020 P(I,J)=INT(10*RND(1))
# 1030 NEXT I
# 1040 NEXT J
# 1050 RETURN
# 1099 END

from random import choice,randrange
import math   

#functions:
def getGuess(turn):
    print("\nTurn No %d" % (turn))
    xresult = 'unknown'
    while xresult != 'good':
        x = input('\tWhat is your guess X value? ')
        xresult = checkInput(x)
    yresult = 'unknown'
    while yresult != 'good':
        y = input('\tWhat is your guess Y value? ')
        yresult = checkInput(y)
    return(int(x),int(y))

def checkInput(entered):
    if entered.isdigit() != True:
        print('\t\tNot a whole number. Try again.')
        return 'notgood'
    elif int(entered) > 9:
        print('\t\tBigger than 9. Try again.')
        return 'notgood'
    else:
        return 'good'

def setMugwumps():
    mugwumps = []
    gridrange = range(0,10)
    for num in range(1,5):
        x = choice(gridrange)
        y = choice(gridrange)
        mugwumps.append({'num':num, 'matched':'False', 'x':x, 'y':y})
    #print(mugwumps) 
    return mugwumps

def calcDistance(g_x, g_y, mw_x, mw_y):
    dist = math.sqrt(((mw_x - g_x)**2) + ((mw_y - g_y)**2))
    return dist 


def main():

    print("The object of this game is to find four mugwumps ")
    print("hidden on a 10 by 10 grid. Homebase is position 0,0. ")
    print("Any guess you make must be two numbers with each number ")
    print("between 0 and 9, inclusive.  First number (x) is distance ")
    print("to right of homebase and second number (y) is distance ")
    print("above homebase. \n\nYou get 10 tries. After each try I will tell ")
    print("you how far you are from each mugwump.\n\n")

    mugwumps = setMugwumps()
    correct = 0

    turn = 0
    while( turn < 11 and correct < 4):
        turn += 1
        guess = getGuess(turn)
    
        for mugwump in mugwumps:
            if mugwump['matched'] == 'True':
                continue
            elif(mugwump['x'] == guess[0] and mugwump['y'] == guess[1]):
                    print("You found mugwump number %d!" % (mugwump['num']))
                    mugwump['matched'] = 'True'
                    correct += 1
            else:
                dist = calcDistance(guess[0], guess[1], mugwump['x'], mugwump['y'])
                print("You are %1.1f units from mugwump %d" % (dist, mugwump['num']))

    if correct == 4:
        print("You got them all in %d turns!" % (turn))

    print("That was fun!")

if __name__ == '__main__':
    main()
