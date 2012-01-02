#include <stdio.h>
#include "stringmaker.h"
#include <stdlib.h>

int strSize;

char *mainString() {
    strSize = 4 + 4 + 11 + 2;
    char *ptr = malloc(sizeof(char) * (strSize + 1));
    unsigned int len = 11;
    sprintf(ptr, "MS%4x%4x%s", len, len, "Hello World");
    return ptr;
}

int getStrSize() {
    return strSize;
}