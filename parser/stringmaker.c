#include <stdio.h>
#include "stringmaker.h"
#include "Parser.h"
#include <string.h>
char *mainString() {
    int len = 160 * 120 * 3;
    initCrc8();
    char ptr[2*len];
    FILE *pfile;
    pfile = fopen("/Users/sam/Desktop/yuaa/server/tester.raw", "r");
    fread(ptr, 1, len, pfile);
    fclose(pfile);
    pfile = fopen("/Users/sam/Desktop/yuaa/server/tester1.raw", "r");
    fread(ptr + len, 1, len, pfile);
    fclose(pfile);
    
    char *a = createProtocolMessage("DI",ptr,len);
    char *b = createProtocolMessage("DI",ptr + len,len);
    
    char final[2 * (len + 5)];
    memcpy(final,a,len+5);
    memcpy(final+len+5, b, len+5);
    return final;
}
