#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <math.h>
#include "Parser.h"

#define CBUFSIZ (60*80)
#define PICBUFSIZ (60*80)
// (160*120*3) must at least be this
char *contentbuf;
int contentidx;

data *craft_info[24][24];

int info_count = 0;

data *get_info(int a, int b) {
    return craft_info[a][b];
}

int info_size() {
    return info_count;
}

void initContentBuf() {
    contentbuf = (char *)malloc(sizeof(char) * CBUFSIZ);
    contentidx = 0;
}

char tagbuf[2];
int tagidx = 0;

char numbuf[4];
int numidx = 0;
int lastlength;

enum parserState {
    TAG,
    CONTENT,
    CHECKSUM,
    MESSAGE,
    SPECIAL
};

int specialCount;

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
        info_count -= (d->length + 5);
        free(d->content);
    } else d = (data *)malloc(sizeof(data));
    char *c = (char *)malloc(sizeof(char) * len);
    memcpy(c, str, len);
    d->length = len;
    d->content = c;
    craft_info[a - 1][b - 1] = d;
    info_count += (d->length + 5);
}

char crc8Table[256];

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
    // printf("Doing crc8 for data: %s, from checksum %.2x, with length %d\n", data, (unsigned char)initialChecksum, length);
    char checksum = initialChecksum;
    
    int i;
    for (i=0;i<length; i++) {
        unsigned char index = (checksum ^ *(data + i));
        checksum = *(crc8Table + index);
    }
    return checksum;
}

void remove_tag(int a, int b) {
    craft_info[a][b] = NULL;
}

char* createProtocolMessage(const char* tag, const char* data, int len)
{   
    //Find checksum
    char checksum = crc8(tag, 0, 2);
    checksum = crc8(data, checksum, len);
    
    int messageLength = 2 + len + 4;
    char* message = (char *)malloc(sizeof(char) * messageLength);
    memcpy(message, tag, 2);
    memcpy(message + 2, data, len);
    sprintf(message + 2 + len, ":%.2x", (unsigned char)checksum);
    
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
                    specialCount = PICBUFSIZ -1;
                    if (tagbuf[0] == 'I' && tagbuf[1] == 'M') state = SPECIAL;
                    else if (tagbuf[0] == 'M' && tagbuf[1] == 'S') state = MESSAGE;
                    else state = CONTENT;
                }
            } else tagidx = 0;
            break;
        }
        case CONTENT: {
            if (c == ':')
                state = CHECKSUM;
            else {
                if (isdigit(c) || c == '+' || c == '-' || c == '.') {
                    if (contentidx < CBUFSIZ) {
                        contentbuf[contentidx] = c;
                        contentidx++;
                    }
                } else {
                    state = TAG;
                    contentidx = 0;
                    return handle_char(c);
                }
            }
            break;
        }
        case CHECKSUM: {
            numbuf[numidx] = c;
            if (numidx == 0) {
                numbuf[numidx++] = c;
            } else {
                state = TAG;
                numidx = 0;
                char check;
                if (sscanf(numbuf, "%2x", &check) == 1) {
                    char checksum = crc8(tagbuf,0,2);
                    checksum = crc8(contentbuf, checksum, contentidx);
                    printf("Checksum: %x, check: %x\n", (unsigned char)checksum, (unsigned char)check);
                    if (checksum == check) {
                        update_tag(to_int(tagbuf[0]), to_int(tagbuf[1]), contentbuf, contentidx);
                        contentidx = 0;
                        return tagbuf;
                    }
                }
                contentidx = 0;
                return handle_char(c);
            }
            break;
        }
        case SPECIAL: {
            if (contentidx == specialCount) {
                state = TAG;
                update_tag(to_int(tagbuf[0]), to_int(tagbuf[1]), contentbuf, contentidx);
                numidx = 0;
                contentidx = 0;
                return tagbuf;
            }
            contentbuf[contentidx++] = c;
            break;
        }
        case MESSAGE: {
            numbuf[numidx++] = c;
            if (numidx == 4) {
                numidx = 0;
                int result;
                if (sscanf(numbuf, "%4x", (unsigned int *)&result) == 1) {
                    if (lastlength) {
                        if (lastlength == result) {
                            specialCount = lastlength;
                            state = SPECIAL;
                            break;
                        } else state = TAG;
                    } else lastlength = result;
                } else state = TAG;
            }
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

