#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <math.h>
#include "Parser.h"

int to_int(char c) {
	if (!isupper(c)) return 0;
	return c - 'A' + 1;
}

char to_char(int i) {
    int a = i+'A' - 1;
	return a;
}

void update_tag(int a, int b, char *str, int len) {
    if (craft_info[a - 1][b - 1]) {
        free(craft_info[a - 1][b - 1]);
    }
    char *c = (char *)malloc(sizeof(char) * len);
    strncpy(c, str, len);
    data *d = (data *)malloc(sizeof(data));
    d->length = len;
    d->content = c;
    craft_info[a - 1][b - 1] = d;
}

char crc8Table[255];

void initCrc8()
{
    //For each possible byte value...
    int i;
    for (i = 0;i < 256;i++)
    {
        //For "each bit" in that value, from high to low
        int valueBits = i;
        int j;
        for (j = 0;j < 8;j++)
        {
            //If that bit is set
            if (valueBits & 128)
            {
                valueBits <<= 1;
                //The remaining amount is xored with
                //A magical number that messes everything up! =]
                valueBits ^= 0xD5;
            }
            else
            {
                //Shift that bit out (also multiple remainder)
                valueBits <<= 1;
            }
        }
        crc8Table[i] = valueBits;
    }
}

//Calculates the CRC-8 checksum of the given data string
//Starting with a given initialChecksum so that multiple
//Calls may be strung together. Use 0 as a default.
char crc8(const char* data, char initialChecksum, int length)
{
    char checksum = initialChecksum;
    int i;
    for (i=0;i<length; i++)
    {
        checksum = crc8Table[checksum ^ *(data + i)];
    }
    return checksum;
}

char* createProtocolMessage(const char* tag, const char* data)
{
    int len = strlen(data);
    
    //Find checksum
    char checksum = crc8(tag, 0, 2);
    checksum = crc8(data, checksum, len);
    
    //Length = tag + data + ':' + checksum + '\0'
    int messageLength = strlen(tag) + len + 4;
    char* message = (char *)malloc(sizeof(char) * messageLength);
    sprintf(message, "%s%s:%.2x", tag, data, (unsigned char)checksum);
    return message;
}


int update_cache(char *init) {
    char *str = init;
    while (str[0] != '\0') {
        char check;
        char checksum;
        char *colon;
        int len;
        char *datastring;
        int width;
        int height;
        char *mystring = str;
        
        if (mystring[0] == 'D' && mystring[1] == 'I') {
            int werr = sscanf(mystring + 2, "%4d", &width);
            int herr = sscanf(mystring + 6, "%4d", &height);
            if (!(herr && werr)) {
                printf("Garbled image data");
                return 1;
            }
            len = width*height*2;
            datastring = mystring + 10;
            colon = datastring + len;
        } else {
            colon = strchr(mystring, ':');
            len = colon - (mystring + 2);
            if (colon == NULL) {
                printf("Couldn't find colon\n");
                return 1;
            }
            datastring = mystring + 2;
        }
        
        int a = to_int(mystring[0]);
        int b = to_int(mystring[1]);
        if (!(a && b)) {
            printf("Invalid tag\n");
            return 1;
        }
        
        if (sscanf(colon + 1 , "%2x", (unsigned int *)&check) != 1) {
            printf("Parsing hex failed\n");
            return 1;
        }
        checksum = crc8(mystring,0,2);
        checksum = crc8(mystring+2, checksum,len);
        if ((unsigned char)check != (unsigned char)checksum) {
            printf("Checksum %x != checksum %x\n", (unsigned char)check, (unsigned char)checksum);
            return 1;
        }
        
        if (!tag_index) tag_index = 0;
        if (tag_index < TAGLISTSIZE - 2) { // leave room for null
            updated_tags[tag_index] = mystring[0];
            updated_tags[tag_index + 1] = mystring[1];
            tag_index += 2;
        }

        update_tag(a,b,datastring,len);
        str = colon + 3;
    }
    return 0;
}
