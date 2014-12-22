import sys

def translate_register(item):
    code=""
    if(item=="R0"):
        code="000"
    elif(item=="R1"):
        code="001"
    elif(item=="R2"):
        code="010"
    elif(item=="R3"):
        code="011"
    elif(item=="R4"):
        code="100"
    elif(item=="R4"):
        code="100"
    elif(item=="R5"):
        code="101"
    elif(item=="R6"):
        code="110"
    elif(item=="R7"):
        code="111"
    else:
        print "ERROR: register unknown: "
        print item
        exit(1)
    return code



def translate(item):
    code=""
    if(item[0]=='R'):
        code=translate_register(item)
    else:
        code=translate_cop(item)
   
    return code
    
def convert_number(number):
    if '0x' in number:
        code=c=bin(int(number,16))[2:]
    else:
        code=bin(int(number))[2:]
    
    return code


def translate_items(items):
    code=""
    cop=items[0]
    if(cop=="NOP"):
        code=code.zfill(16)
    elif(cop=="ADD"):
        code="0001"
        code+=translate_register(items[1])
        code+=translate_register(items[2])
        code+="000" #free bits
        code+=translate_register(items[3])
    elif(cop=="SUB"):
        code="0010"
        code+=translate_register(items[1])
        code+=translate_register(items[2])
        code+="000" #free bits
        code+=translate_register(items[3])
    elif(cop=="MOV"):
        code="0011"
        code+=translate_register(items[1])
        number=convert_number(items[2]).zfill(9) #inmediate
        code+=number
    elif(cop=="CMP"):
        code="0100"
        code+=translate_register(items[1])
        code+=translate_register(items[2])
        code+="000" #free bits
        code+=translate_register(items[3])
    elif(cop=="BNZ"):
        code="0101"
        code+="000" #free bits
        code+=translate_register(items[1])
        code+="000" #free bits
        code+=translate_register(items[2])
    elif(cop=="LD"):
        code="0110"
        code+=translate_register(items[1])
        code+=translate_register(items[2])
        number=convert_number(items[3]).zfill(6) #inmediate
        code+=number
    elif(cop=="ST"):
        code="0111"
        code+=translate_register(items[1])
        code+=translate_register(items[2])
        number=convert_number(items[3]).zfill(6) #inmediate
        code+=number
    else:
        print "ERROR: instruction unknown: "
        print items
        exit(1)
    return code    

def split_n(binary_string, n):
    code=""
    n=4
    for i in range(0, len(binary_string), n):
        code+=binary_string[i:i+n]
        code+=" "
    return code

def splited_to_hex(splited_string):
    code=""
    bytes=splited_string.split(" ")[:-1]
    for i in range(0, len(bytes), 2):

        code+=hex(int(bytes[i],2))[2:]
        code+=hex(int(bytes[i+1],2))[2:]
    return code


def create_file(init_address, code):
    body=""
    header=    "// memory data file (do not edit the following line - required for mem load use)\n"
    header+=   "// instance=/proc_tb/my_proc/my_fetch/my_memory/mem\n"
    header+=   "// format=mti addressradix=h dataradix=h version=1.0 wordsperline=16"
    body+= header
    j=0
    for i in range(0,2048):
        if(i%16==0):
            body+= "\n"+ hex(i)[2:].rjust(3," ")+": "
        if (i > init_address -1 and i <init_address+len(code)/4):
            body+= code[j]
            body+= code[j+1]
            body+= code[j+2]
            body+= code[j+3]
            body+= " "
            j+=4
        else:
            body+= "xxxx "
    print body


#MAIN
code=""

if len(sys.argv) != 2:
    print "Usage " + str(sys.argv[0]) + " generate_memory[0|1]"
    exit(0)

generateMemory = (sys.argv[1] == "1")


for line in sys.stdin:
    if line[0][0]!="#" and line != "\n":
        if '\n' in line:
             line=line[:-1]
        items=line.split(" ")
        decoded_line= translate_items(items)
        if not generateMemory:
            print line.ljust(10," ")+ "\t"+decoded_line
        splited_binary= split_n(decoded_line, 4)
        #print splited_binary
        code+= splited_to_hex(splited_binary)
#print code
if generateMemory:
   create_file(12, code)
         
        

