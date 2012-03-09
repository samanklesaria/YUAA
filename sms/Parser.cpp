#include "WProgram.h"
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <math.h>
#include "Parser.h"

char crc8Table[256];

void prepCrc()
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
    printf("Doing crc8 for data: %s, from checksum %.2x, with length %d\n", data, (unsigned char)initialChecksum, length);
    char checksum = initialChecksum;
    
    int i;
    for (i=0;i<length; i++) {
        unsigned char index = (checksum ^ *(data + i));
        checksum = *(crc8Table + index);
    }
    return checksum;
}

char* createProtocolMessage(char *message, const char* tag, const char* data, int len)
{   
    //Find checksum
    char checksum = crc8(tag, 0, 2);
    checksum = crc8(data, checksum, len);
    
    memcpy(message, tag, 2);
    memcpy(message + 2, data, len);
    sprintf(message + 2 + len, ":%.2x", (unsigned char)checksum);
    
    return message;
}


result *handle_char(char c, parserState *p) {
    switch (p->state) {
        case TAG: {
            if (isalpha(c)) {
                p->tagbuf[p->tagidx] = c;
                (p->tagidx)++;
                if (p->tagidx == 2) {
                    p->tagidx = 0;
                    Serial.print("Handling tag: ");
                    Serial.write((uint8_t *)(p->tagbuf), 2);
                    Serial.print("\n");
                    // printf("Handling tag %2s\n", p->tagbuf);
                    (p->specialCount) = CBUFSIZ -1;
                    if (p->tagbuf[0] == 'I' && p->tagbuf[1] == 'M') (p->state) = SPECIAL;
                    else if (p->tagbuf[0] == 'M' && p->tagbuf[1] == 'S') (p->state) = MESSAGE;
                    else (p->state) = CONTENT;
                }
            } else p->tagidx = 0;
            break;
        }
        case CONTENT: {
            if (c == ':')
                (p->state) = CHECKSUM;
            else {
                if (isdigit(c) || c == '+' || c == '-' || c == '.') {
                    if ((p->contentidx) < CBUFSIZ) {
                        (p->contentbuf)[p->contentidx] = c;
                        (p->contentidx)++;
                    }
                } else {
                    (p->state) = TAG;
                    printf("Invalid syntax. Restarting");
                    (p->contentidx) = 0;
                    return handle_char(c, p);
                }
            }
            break;
        }
        case CHECKSUM: {
            (p->numbuf)[p->numidx] = c;
            if (p->numidx == 0) {
                (p->numbuf)[(p->numidx)++] = c;
            } else {
                (p->state) = TAG;
                p->numidx = 0;
                int scanner = sscanf((p->numbuf), "%2x", &(p->check));
                if (scanner == 1) {
                    p->checksum = crc8(p->tagbuf,0,2);
                    p->checksum = crc8((p->contentbuf), p->checksum, p->contentidx);
                    Serial.print("Checksum: ");
                    Serial.print(p->checksum, HEX);
                    Serial.print(" check: ");
                    Serial.println(p->check, HEX);
                    // printf("Checksum: %x, check: %x\n", p->checksum, p->check);
                    if (p->checksum == p->check) {
                        p->parserResult.length = p->contentidx;
                        p->parserResult.content = (p->contentbuf);
                        p->parserResult.tag = p->tagbuf;
                        (p->contentidx) = 0;
                        return &(p->parserResult);
                    }
                }
                p->contentidx = 0;
                return handle_char(c, p);
            }
            break;
        }
        case SPECIAL: {
            if (p->contentidx == (p->specialCount)) {
                p->parserResult.length = p->contentidx;
                p->parserResult.content = (p->contentbuf);
                p->parserResult.tag = p->tagbuf;
                p->state = TAG;
                p->numidx = 0;
                (p->contentidx) = 0;
                return &(p->parserResult);
            }
            (p->contentbuf)[(p->contentidx)++] = c;
            break;
        }
        case MESSAGE: {
            (p->numbuf)[(p->numidx)++] = c;
            if (p->numidx == 4) {
                p->numidx = 0;
                int result;
                if (sscanf((p->numbuf), "%4x", (unsigned int *)&result) == 1) {
                    if (p->lastlength) {
                        if (p->lastlength == result) {
                            (p->specialCount) = p->lastlength;
                            p->state = SPECIAL;
                            break;
                        } else p->state = TAG;
                    } else p->lastlength = result;
                } else p->state = TAG;
            }
        }
    }
    return NULL;
}


