#include <stdio.h>
#include "stringmaker.h"
#include "Parser.h"
#include <stdlib.h>

int strSize;

char *mainString() {
    
    int len = 60*80;
    initCrc8();
    strSize = 2*len + 4;
    char *ptr = (char *)malloc(sizeof(char) *strSize);
    FILE *pfile;
    ptr[0] = 'I';
    ptr[1] = 'M';
    pfile = fopen("/Users/sam/Desktop/yuaa/server/tester.raw", "r");
    fread(ptr + 2, 1, len, pfile);
    fclose(pfile);
    ptr[len + 2] = 'I';
    ptr[len + 3] = 'M';
    pfile = fopen("/Users/sam/Desktop/yuaa/server/tester1.raw", "r");
    fread(ptr + len + 4, 1, len, pfile);
    fclose(pfile);
    return ptr;
}

int getStrSize() {
    return strSize;
}
