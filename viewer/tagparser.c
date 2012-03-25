#include "tagparser.h"
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

bool isdatachar(int c)
{
    return isdigit(c) || c == '+' || c == '-' || c == '.';
}

bool islowerhex(int c)
{
    return isdigit(c) || (c >= 'a' && c <= 'f');
}

//Parses an AKP tag byte by byte as bytes are passed in from
//each call to this method. The internal state of the parser is
//maintained in tpData and this method will only return true for a properly
//parsed tag when the tag has been received and parsed in full.
//At that time, tag and data of tpData will be filled.
//If the parser just updates its internal state because it gets
//more of a tag, or regresses as it found a tag was invalid,
//false is returned and tag and data are not touched.
bool parseTag(char currentByte, TagParseData* tpData)
{
    //Make sure state is initialized
    if (!tpData->hasInited)
    {
        tpData->hasInited = true;
        tpData->tagByte1 = -1;
        tpData->tagByte2 = -1;
        tpData->dataIndex = -1;
        tpData->hasColon = false;
        tpData->checkByte1 = -1;
        tpData->checkByte2 = -1;
    }
    
    //Do we need a tag?
    if (tpData->dataIndex == -1)
    { 
        //Have we finished getting one?
        //Also, we choose to explicitly ignore MS (message) and IM (image) tags
        //Because the arduino is neither suited to them or the intended target of them.
        if (isupper(tpData->tagByte1) && isupper(tpData->tagByte2) &&
           (isdatachar(currentByte) || currentByte == ':') &&
           !(tpData->tagByte1 == 'M' && tpData->tagByte2 == 'S') &&
           !(tpData->tagByte1 == 'I' && tpData->tagByte2 == 'M'))
        {
            //Wonderful! We can start getting data!
            tpData->dataIndex = 0;
        }
        else
        {
            //What a pity! Maybe next time!
            tpData->tagByte1 = tpData->tagByte2;
            tpData->tagByte2 = currentByte;
            return false;
        }
    }

    //Add another data character if we can
    if (!tpData->hasColon && isdatachar(currentByte) && tpData->dataIndex < MAX_DATA_SIZE)
    {
        tpData->dataBuffer[tpData->dataIndex++] = currentByte;
        return false;
    }
    else if (!tpData->hasColon)
    {
        //We must have a colon here to terninate the data or abort.
        if (currentByte == ':')
        {
            tpData->hasColon = true;
            //Done with data, null terminate it
            tpData->dataBuffer[tpData->dataIndex] = '\0';
            return false;
        }
    }
    else if (tpData->checkByte1 == -1)
    {
        //Check bytes must be lower case hexadecimal or we abort
        if (islowerhex(currentByte))
        {
            tpData->checkByte1 = currentByte;
            return false;
        }
    }
    else if (tpData->checkByte2 == -1)
    {
        //Check bytes must be lower case hexadecimal or we abort
        if (islowerhex(currentByte))
        {
            tpData->checkByte2 = currentByte;
            //Good, now we have everything and can check the entire tag!
            //Convert checksum from two hex digits to a number
            char checkBytes[3];
            checkBytes[0] = tpData->checkByte1;
            checkBytes[1] = tpData->checkByte2;
            checkBytes[2] = '\0';

            //As we have already validated the checkbytes
            //We cannot get an error here unless we have one there
            int readChecksum = (int)strtol(checkBytes, NULL, 16);

            //Prepare a calculated checksum
            char tagBytes[3];
            tagBytes[0] = tpData->tagByte1;
            tagBytes[1] = tpData->tagByte2;
            tagBytes[2] = '\0';
            
            int calculatedChecksum = crc8(tagBytes, 0);
            calculatedChecksum = crc8(tpData->dataBuffer, calculatedChecksum);

            //Of they aren't good we are out of the game,
            //And the currentByte has already been validated
            //As not an upper-case tag candidate!
            if (readChecksum != calculatedChecksum)
            {
                return false;
            }

            //Successfully made tag!
            strncpy(tpData->tag, tagBytes, sizeof(tagBytes));
            strncpy(tpData->data, tpData->dataBuffer, sizeof(tpData->dataBuffer));
            return true;
        }
    }
    //If something fell through, then we had some failure,
    //so we abort and put the currentByte in tagByte2
    //so that a new tag may be begun being searched for
    tpData->tagByte1 = tpData->dataIndex = tpData->checkByte1 = tpData->checkByte2 = -1;
    tpData->hasColon = false;
    tpData->tagByte2 = currentByte;
    return false;
}
