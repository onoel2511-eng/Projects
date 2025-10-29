import random
randNum = None
attempts = 0
lastGuess = None

def startPrompt():
    global attempts
    
    attempts += 1
    prompt = input("Guess the number 1 to 100: ")
    return prompt
    
def getRandInt():
    
    randNum = random.randint(1, 100)
    return randNum
    
def checkInt(inputPrompt):
    global lastGuess
    
    try:
        Num = int(inputPrompt)
        lastGuess = Num
        return Num
    except ValueError:
        try:
            Num = float(inputPrompt)
            lastGuess = Num
            return Num
            
        except ValueError:
            print()

def checkGuess(Num):
    global randNum, attempts, lastGuess
    
    try:
        if Num < randNum:
            print(f"Your guess, {lastGuess}, is too low! Try again!")
            print()
            prompt = startPrompt()
            
            Num = checkInt(prompt)
            
            checkGuess(Num)
            
        elif Num > randNum:
            print(f"Your guess, {lastGuess}, is too high! Try again!")
            print()
            prompt = startPrompt()
            
            #Num = int(prompt)
            Num = checkInt(prompt)
        
            checkGuess(Num)
        else:
            print(f"You guessed the number, {randNum}, in {attempts} attempts!")
            restartPrompt = input("Type 'restart' to re-play: ")
            if restartPrompt == "restart":
                start()
    except TypeError:
        print("What you entered is not number!")
        prompt = startPrompt()
    
        Num = checkInt(prompt)
        
        checkGuess(Num)
        
def start():
    global randNum, attempts
    
    attempts = 0
    
    randNum = getRandInt()
    
    #prompt = input("Guess the number: ")
    prompt = startPrompt()
    Num = checkInt(prompt)
    #Num = int(prompt)
    
    
    checkGuess(Num)
    
start()
