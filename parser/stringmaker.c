#include <stdio.h>
#include "stringmaker.h"
#include "Parser.h"
#include <stdlib.h>

int strSize;

char *mainString() {
    int len = 160 * 120 * 3;
    initCrc8();
    strSize = 2*len + 4;
    char *ptr = (char *)malloc(sizeof(char) *strSize);
    FILE *pfile;
    ptr[0] = 'D';
    ptr[1] = 'I';
    pfile = fopen("/Users/sam/Desktop/yuaa/server/tester.raw", "r");
    fread(ptr + 2, 1, len, pfile);
    fclose(pfile);
    ptr[len + 2] = 'D';
    ptr[len + 3] = 'I';
    pfile = fopen("/Users/sam/Desktop/yuaa/server/tester1.raw", "r");
    fread(ptr + len + 4, 1, len, pfile);
    fclose(pfile);
    return ptr;
}

int getStrSize() {
    return strSize;
}