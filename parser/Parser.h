#ifndef PARSER_LOADED
#define PARSER_LOADED

#define CBUFSIZ (60*80)

enum mode {
    TAG,
    CONTENT,
    CHECKSUM,
    MESSAGE,
    SPECIAL
};

typedef struct result {
    char *tag;
    int length;
    char *content;
} result;

typedef struct parserState {
    int contentidx;
    char contentbuf[CBUFSIZ];
    int tagidx;
    char tagbuf[2];
    char numbuf[4];
    int numidx;
    int lastlength;
    enum mode state;
    int specialCount;
    unsigned char check;
    unsigned char checksum;
    result parserResult;
} parserState;

void prepCrc(void);

char crc8(const char* data, char initialChecksum, int length);

char *createProtocolMessage(char *message, const char* tag, const char* data, int len);

result *handle_char(char c, parserState *pp);

#endif
