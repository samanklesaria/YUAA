#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <math.h>
#include "Parser.h"

#define CBUFSIZ 57600
// (160*120*3) must at least be this
char contentbuf[CBUFSIZ];
int contentidx = 0;

char tagbuf[2];
int tagidx = 0;

char numbuf[2];
int numidx = 0;

#define PICBUFSIZ (160*120*3)

enum parserState {
   TAG,
   CONTENT,
   CHECKSUM,
   PICTURE
};

static enum parserState state = TAG;

int to_int(char c) {
	if (!isupper(c)) return 0;
	return c - 'A' + 1;
}

char to_char(int i) {
    int a = i+'A' - 1;
	return a;
}

void update_tag(int a, int b, char *str, int len) {
    data *d;
    if (craft_info[a - 1][b - 1]) {
        d = (craft_info[a - 1][b - 1]);
        free(d->content);
    } else d = (data *)malloc(sizeof(data));
    char *c = (char *)malloc(sizeof(char) * len);
    strncpy(c, str, len);
    d->length = len;
    d->content = c;
    d->exists = 1;
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
    int len = (int)strlen(data);
    
    //Find checksum
    char checksum = crc8(tag, 0, 2);
    checksum = crc8(data, checksum, len);
    
    //Length = tag + data + ':' + checksum + '\0'
    int messageLength = (int)strlen(tag) + len + 4;
    char* message = (char *)malloc(sizeof(char) * messageLength);
    sprintf(message, "%s%s:%.2x", tag, data, (unsigned char)checksum);
    return message;
}


char *handle_char(char c) {
    switch (state) {
        case TAG: {
            int a = to_int(c);
            if (a) {
                tagbuf[tagidx] = c;
                tagidx++;
                if (tagidx == 2) {
                    tagidx = 0;
                    printf("Handling tag %2s\n", tagbuf);
                    if (tagbuf[0] == 'D' && tagbuf[1] == 'I') state = PICTURE;
                    else state = CONTENT;
                }
            } else tagidx = 0;
            break;
        }
        case CONTENT: {
            if (c == ':')
                state = CHECKSUM;
            else {
                if (contentidx < CBUFSIZ) {
                    contentbuf[contentidx] = c;
                    contentidx++;
                }
            }
            break;
        }
        case CHECKSUM: {
            numbuf[numidx] = c;
            if (numidx == 0) {
                numbuf[numidx] = c;
                numidx++;
            } else {
                char check;
                if (sscanf(numbuf, "%2x", (unsigned int *)&check) == 1) {
                    char checksum = crc8(tagbuf,0,2);
                    checksum = crc8(contentbuf, checksum, contentidx);
                    printf("Checksum: %x, check: %x\n", (unsigned int)checksum, (unsigned int)check);
                    if (checksum == check) {
                        state = TAG;
                        update_tag(to_int(tagbuf[0]), to_int(tagbuf[1]), contentbuf, contentidx);
                        numidx = 0;
                        contentidx = 0;
                        return tagbuf;
                    }
                }
                if (contentidx + 2 < CBUFSIZ) {
                    strncpy(contentbuf + contentidx, numbuf, 2);
                    contentidx += 2;
                }
                state = CONTENT;
            }
            break;
        }
        case PICTURE: {
            if (contentidx == PICBUFSIZ) {
                if (c == ':') state = CHECKSUM;
                else state = TAG;
                break;
            }
            contentbuf[contentidx] = c;
            contentidx++;
            break;
        }
    }
    return NULL;
}

void parse_string(char *c) {
    while (*c != '\0') {
        handle_char(*c);
        c++;
    }
}

