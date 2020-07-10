import os,sys,re

print(sys.path[0])

FILE = './{}.s'.format("snake")
TARGET = './func/inst/my_test.S'
HEAD = '''
#include <asm.h>
#include <regdef.h>
#include <inst_test.h>

LEAF(my_test)
    LI (sp, 0xbfcf0000) 

    b snake_main
    nop
'''
END = '''
END(my_test)
'''

ass = ""
with open(FILE) as F:
    ass = F.read()
ass = ass.replace("$sp", 'sp')
ass = ass.replace("$fp", 'fp')

ass = HEAD + ass + END

# print(ass)
# print(re.sub(r'\..*\n\t', "", ass))
ass = re.sub(r'\..*\n\t', "", ass)

with open(TARGET, 'w') as F:
    F.write(ass)
# print("ok")