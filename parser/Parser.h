typedef struct data {
    int length;
    char *content;
} data;

int to_int(char c);

char to_char(int i);

data *get_info(int a, int b);

void update_tag(int a, int b, char *str, int len);

void remove_tag(int a, int b);

int update_cache(char *init);

void initCrc8(void);

char crc8(const char* data, char initialChecksum, int length);

char *createProtocolMessage(const char* tag, const char* data, int len);

void parse_string(char *c);

char *handle_char(char c);

int info_size(void);

void initContentBuf(void);
