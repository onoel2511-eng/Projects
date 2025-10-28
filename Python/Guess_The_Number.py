import random
randNum = None
attempts = 0

def startPrompt():
    global attempts
    
    attempts += 1
    prompt = input("Guess the number 1 to 100: ")
    return prompt
    
def getRandInt():
    
    randNum = random.randint(1, 100)
    return randNum
    
def checkInt(inputPrompt):
    try:
        Num = int(inputPrompt)
        return Num
    except ValueError:
        try:
            Num = float(inputPrompt)
            return Num
            
        except ValueError:
            print("What you entered is not a number!")

def checkGuess(Num):
    global randNum, attempts
    
    if Num < randNum:
        print("Too low, try again!")
        prompt = startPrompt()
        
        Num = checkInt(prompt)
        
        checkGuess(Num)
        
    elif Num > randNum:
        print("Too high, try again!")
        prompt = startPrompt()
        
        #Num = int(prompt)
        Num = checkInt(prompt)
        
        checkGuess(Num)
    else:
        print(f"You guessed the number, {randNum}, in {attempts} attempts!")
        restartPrompt = input("Type 'restart' to re-play: ")
        if restartPrompt == "restart":
            start()
          
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
