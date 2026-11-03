import random,sys
random.seed(int(sys.argv[1]))
def R(f7,rs2,rs1,f3,rd,op=0x33): return (f7<<25)|(rs2<<20)|(rs1<<15)|(f3<<12)|(rd<<7)|op
def I(imm,rs1,f3,rd,op=0x13): return ((imm&0xfff)<<20)|(rs1<<15)|(f3<<12)|(rd<<7)|op
def S(imm,rs2,rs1,f3=2): return (((imm>>5)&0x7f)<<25)|(rs2<<20)|(rs1<<15)|(f3<<12)|((imm&0x1f)<<7)|0x23
prog=[]
for r in range(1,14): prog.append(I(random.randint(-2000,2000),0,0,r))
prog.append(I(0x700,0,0,14))
ops=[(0,0),(0x20,0),(0,4),(0,6),(0,7),(0,1),(0,5),(0,2),(1,0)]
for n in range(300):
    k=random.random()
    rd=random.randint(1,13); a=random.randint(0,13); b=random.randint(0,13)
    if k<0.65:
        f7,f3=random.choice(ops); prog.append(R(f7,b,a,f3,rd))
    elif k<0.8: prog.append(I(random.randint(-100,100),a,0,rd))
    elif k<0.9:
        off=4*random.randint(0,15); prog.append(S(off,a if False else b,14))
    else:
        off=4*random.randint(0,15); prog.append(I(off,14,2,rd,0x03))
for i in range(1,14): prog.append(S(64+4*i,i,14))
prog.append(0x6f)
open('fw.hex','w').write(''.join('%08X\n'%x for x in prog))
print(len(prog))
