#define CBUFSIZ (60*80)

enum mode {
    TAG,
    CONTENT,
    CHECKSUM,
    MESSAGE,
    SPECIAL
};

struct result {
    char *tag;
    int length;
    char *content;
};

struct parserState {
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
    struct result parserResult;
};
