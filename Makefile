# Copyright(C) 2016, Red Hat, Inc., Stanislav Kozina
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

PROG=kabi-dw
SRCS=generate.c ksymtab.c utils.c main.c stack.c objects.c hash.c
SRCS += compare.c show.c

CC=gcc
CFLAGS=-Wall -O2 -g --std=gnu99 -D_GNU_SOURCE -c
LDFLAGS=-ldw -lelf

YACC=bison
YACCFLAGS=-d -t

FLEX=flex
FLEXFLAGS=

OBJS=$(SRCS:.c=.o)
OBJS+=parser.yy.o parser.tab.o

.PHONY: clean all depend debug asan

all: $(PROG)

debug: CFLAGS+=-DDEBUG -fsanitize=address
debug: LDFLAGS:=-lasan $(LDFLAGS)
debug: FLEXFLAGS+=-d
debug: $(PROG)

asan: CFLAGS+=-fsanitize=address
asan: LDFLAGS:=-lasan $(LDFLAGS)
asan: $(PROG)

$(PROG): $(OBJS)
	$(CC) -o $(PROG) $(OBJS) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) $< -o $@

parser.tab.c: parser.y
	$(YACC) $(YACCFLAGS) parser.y

parser.yy.c: parser.tab.c parser.l parser.h
	$(FLEX) $(FLEXFLAGS) -o parser.yy.c parser.l

depend: .depend

.depend: $(SRCS)
	$(CC) $(CFLAGS) -MM $^ > ./.depend

-include .depend

clean:
	rm -f $(PROG) $(OBJS) .depend parser *.tab.c *.tab.h *.yy.c
