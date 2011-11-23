char *craft_info[24][24];

int to_int(char c);

char to_char(int i);

void update_tag(int a, int b, char *str, int len);

int update_cache(char *init);

void initCrc8(void);

char crc8(const char* data, char initialChecksum, int length);

char* createProtocolMessage(const char* tag, const char* data);