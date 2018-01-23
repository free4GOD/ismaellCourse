#!/usr/bin/python3
# A string is a palindrome if it reads the same in both directions.
# Only alphanumeric characters are considered, any other character is
# ignored/skipped.

# New task:
# Now we're comparing Zettabyte+ data records for palindromeness.
# A function, called GetChunk(offset start, offset end) returns the
# desired portion, GetLength() returns the length of the data record.
# start = 0
# end = 4MB

def isValid(char):
  char = char.upper()
  return (char >= '0' and char <= '9') or (char >= 'A' and char <= 'Z')

path = '/home/barbanegra/hackspaceuy/cursoIsmaell/source.txt'
with open(path,'r') as file:
  for line in file:
    print(line)
    end = len(line)-2
    for i in range(0, end):
      if isValid(line[i]):
        while (not isValid(line[end])) and end > i:
          end = end - 1
        if (line[i].upper() == line[end].upper()):
          end = end - 1
        else:
          print('NO es palindromo')
          break
        if i >= end:
          print('SI es palindromo')
          break
