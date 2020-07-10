TOPDIR=$(shell pwd)
CROSS_COMPILE:=mipsel-linux-
SRC := snake
FLAG := -S -O0

all: ${TOPDIR}/${SRC}.s
	python trans.py

${TOPDIR}/${SRC}.s: ${TOPDIR}/${SRC}.c
	${CROSS_COMPILE}gcc ${FLAG} $<

clean:
	rm ${TOPDIR}/${SRC}.s
