length = int(input("Enter the the length :"))
width = int(input("Enter the width :"))
Area = length * width
print(Area)

#while loop

Age  = int(input("Enter your age : "))

while Age < 0:
    print("Age can't be negative:")
    Age  = int(input("Enter your age : "))
print(f"You are {Age} years old")


num = int(input("Enter a # between 1-10 :"))
while num < 1  or num > 10:
    print(f"{num} is not valid")
    num = int(input("Enter a # between 1-10 :"))
print(f"You number is {num}")

