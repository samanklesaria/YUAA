#include "types.h"
#include <SoftwareSerial.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <math.h>
SoftwareSerial bigArduino(7, 8);

#define CBUFSIZ (60*80)

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
    // printf("Doing crc8 for data: %s, from checksum %.2x, with length %d\n", data, (unsigned char)initialChecksum, length);
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

struct result *handle_char(char c, struct parserState *p) {
    int unusedVal = p->state;
    return NULL;
    // bigArduino.println("Handling a char");
    switch (p->state) {
        case TAG: {
            if (isupper(c)) {
                p->tagbuf[p->tagidx] = c;
                (p->tagidx)++;
                if (p->tagidx == 2) {
                    p->tagidx = 0;
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
                int scanner = sscanf((p->numbuf), "%2x", (unsigned int *)&(p->check));
                if (scanner == 1) {
                    p->checksum = crc8(p->tagbuf,0,2);
                    p->checksum = crc8((p->contentbuf), p->checksum, p->contentidx);
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

// end of that stuff

#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <setjmp.h>

#include <ctype.h>
#include <setjmp.h>

#define KILLSIGNAL "KIL"
#define LOCSIGNAL "LOC"
#define INFOSIGNAL "INF"
#define ADDSIGNAL "ADD"

#define LACTAG to_int('L'), to_int('C')
#define LATTAG to_int('L'), to_int('T')
#define LONTAG to_int('L'), to_int('N')
#define MCCTAG to_int('M'), to_int('C')
#define MNCTAG to_int('M'), to_int('N')
#define CIDTAG to_int('C'), to_int('I')
#define KILLTAG to_int('L'), to_int('V')

#define BUFFSIZE 100
#define DELAYTIME 120000
#define CMDLEN 30

char at_buffer[BUFFSIZE];
int buffidx;
char cmd[CMDLEN];
char number[12];
char numbers[45] = "1651747799312033470933";
int numsidx = 22;

int inSetup = 0;
int notErring = 0;

char mcc_buffer[15];
int mcc_len = 15;
char lac_buffer[32];
int lac_len;
char lat_buffer[16];
int lon_len;
char lon_buffer[16];
int lat_len;

void str_cache(void printer(char *c)) {
  printer(mcc_buffer);
  printer(lac_buffer);
  printer(lat_buffer);
  printer(lon_buffer);
}

jmp_buf restarter;
jmp_buf init_restarter;

struct parserState ps;

static unsigned long timestamp = 0;
static unsigned long timeoutstamp = 0;

int cellAvailable() {
    Serial.available();
}

char cellRead() {
    return Serial.read();
}

void serialPrint(char *c) {
  Serial.print(c);
}

void arduinoPrint(char *c) {
  bigArduino.print(c);
}

int maybe_read_byte(int (*avail)(), char (*reader)()) {
  if ((*avail)() > 0) {
          char c = (*reader)();
          if (c == '\n') return 0;
          if (c == '\r') {
              at_buffer[buffidx] = '\0';
              return 1;
          }
          if (!(buffidx == BUFFSIZE - 1)) at_buffer[buffidx++] = c;
  }
  return 0;
}

void read_from(int (*avail)(), char (*reader)()) {
    buffidx = 0;
    while (1) {
        if (maybe_read_byte(avail, reader)) return;
    }
}

void parseNumber() {
  char *a = strchr(at_buffer, '"') + 2;
  strncpy(number, a, min(11, strlen(at_buffer)));
} 

void wait_for(char *a) {
    while (1) {
        delay(500);
        read_from(cellAvailable, cellRead);
        bigArduino.print("Waiting with line ");
        bigArduino.println(at_buffer);
        if (strstr(at_buffer,a)) return;
        if (processor() == 1) return;
    }
}

void wait_for_byte(char a) {
    while (1) {
        if (Serial.available() > 0) {
            char inc = Serial.read();
            /*
            if (inc == '+') {
              // setupSim();
              longjmp(restarter, 0);
            }
            */
            if (inc == a) return;
        }
    }
}

void startCall(char *phn) {
    bigArduino.println("starting call to ");
    bigArduino.write((const uint8_t *)phn, 11);
    bigArduino.print("\n");
    delay(500);
    Serial.print("AT+CMGS=\"");
    Serial.write((uint8_t*)phn, 11);
    // delay(500);
    Serial.print("\"\r");
    wait_for_byte('>');
}

void endCall() {
    Serial.write(26);
    wait_for("OK");
    bigArduino.println("ended call");
}

void makeCall () {
  delay(1000);
  int i;
  for (i = 0; i < numsidx; i += 11) {
    startCall(numbers + i);
    //Serial.print("Hi");
    str_cache(serialPrint);
    endCall();
  }
}

void killCall() {
  int i;
  for (i = 0; i < numsidx; i += 10) {
    startCall(numbers + i);
    Serial.print("KILLED");
    endCall();
  }
}

int processor() {
        if (strstr(at_buffer,"ERROR")) {
             bigArduino.println("ERROR");
            delay(1000);
            if (inSetup) {
              longjmp(init_restarter, 0);
            }
            setupSim();
            longjmp(restarter, 0);
        };
        if (strstr(at_buffer,"+CMT")) {
          bigArduino.println("Parsing a number");
          delay(1000);
          parseNumber();
          read_from(cellAvailable, cellRead);
          if (strstr(at_buffer, KILLSIGNAL)) { if (notErring) notErring = 0; bigArduino.println("KILLING"); killCall(); }
          if (strstr(at_buffer, INFOSIGNAL)) { delay(1000); bigArduino.println("CALLING"); delay(1000); makeCall(); }
          if (strstr(at_buffer, ADDSIGNAL)) { bigArduino.println("ADDING"); addNumber(); }
          Serial.println("AT+CMGD=1,4");
          wait_for("OK");
          return 0;
        };
        if (strstr(at_buffer, "+SIND: 4")) {
          bigArduino.println("RESTARTING");
          if (inSetup) {
              bigArduino.println("Baking");
              delay(1000);
              longjmp(init_restarter, 0);
            }
            bigArduino.println("Something sucks!");
            delay(500);
            setupSim();
            longjmp(restarter, 0);
        }
        if (strstr(at_buffer, "+CREG")) {
              bigArduino.println("CREGGING");
              delay(500);
              store_lac_cid();
              delay(1000);
              return 1;
        };
        return 0;
}

void store_mcc_mnc() {
  while (1) {
    Serial.println("AT+COPS=0");
    wait_for("OK");
    Serial.println("AT+COPS?");
    read_from(cellAvailable, cellRead);
    read_from(cellAvailable, cellRead);

    char *firstComma = strchr(at_buffer,',');
    if (firstComma) {
      char *mcc_mnc = strchr(firstComma+1,',') + 1;
      bigArduino.println("\nThe MC Value is: ");
      createProtocolMessage(mcc_buffer, "MC", mcc_mnc, 3);
      bigArduino.write((const uint8_t *)mcc_buffer, 8);
      delay(500);
      bigArduino.print("Looking in ");
      delay(500);
      bigArduino.write((const uint8_t *)mcc_mnc + 3, 2);
      delay(500);
      bigArduino.println("\nThe MN Value is: ");
      delay(500);
      createProtocolMessage(mcc_buffer + 8, "MN", mcc_mnc + 3, 2);
      bigArduino.write((const uint8_t *)(mcc_buffer + 8),7);
      *(mcc_buffer + 15) = '\0';
      
      delay(500);
      wait_for("OK");
      break;
    }
    wait_for("OK");
  }
  bigArduino.println("Completed mnc");
}

void store_lac_cid() {
    char *start = strchr(at_buffer, ',') + 1;
    char lacstr[6];
    unsigned int lac;
    char cidstr[6];
    unsigned int cid;
    sscanf(start,"0x%4X,0x%4X", &lac, &cid);
    sprintf(lacstr, "%u", lac);
    sprintf(cidstr, "%u", cid);
    int laclen = strlen(lacstr);
    int cidlen = strlen(cidstr);
    lac_len = laclen + cidlen;
    bigArduino.println("LAC buffer is ");
    bigArduino.write((const uint8_t *)lac_buffer, laclen);
    delay(500);
    createProtocolMessage(lac_buffer, "LC", lacstr, laclen);
    // bigArduino.write((const uint8_t *)lac_buffer, laclen + 5);
    delay(500);
    createProtocolMessage(lac_buffer + laclen + 5, "CI", cidstr, cidlen);
    // bigArduino.write((const uint8_t *)(lac_buffer + laclen + 5), cidlen + 5);
    *(lac_buffer + laclen + cidlen + 10) = '\0';
    bigArduino.println("Done with LAC/CID");
}

void addNumber() {
  strcpy(numbers + numsidx, number);
  numsidx += 11;
}

void update_loc() {
    int b = maybe_read_byte(cellAvailable, cellRead);
    if (b) {
       buffidx = 0;
       setjmp(restarter);
       int a = processor();
       if (a) return;
    }
    if (millis() - timestamp > DELAYTIME) {
      timestamp = millis();
      if (!notErring) {
        setjmp(restarter);
        makeCall();
      }
    }
}

void setupSim() { 
    inSetup = 1;
    setjmp(init_restarter);
    bigArduino.println("Setting up SIM");
    Serial.println("AT+CMGF=1");
    wait_for("OK");
    bigArduino.println("Formatting complete");
    setjmp(init_restarter);
    Serial.println("AT+CMGD=1,4");
    wait_for("OK");
     bigArduino.println("Deleting complete");
    
    // Serial1.println("AT+SBAND=7");
    // wait_for("OK");
    
    setjmp(init_restarter);
    store_mcc_mnc();
    
    setjmp(init_restarter);
    Serial.println("AT+CNMI=3,3,0,0");
    wait_for("OK");
     bigArduino.println("Talkback complete");
    
    setjmp(init_restarter);
    Serial.println("AT+CREG=2");
    bigArduino.println("Just tried to creg");
    wait_for("OK");
    bigArduino.println("Cregging complete");
    inSetup = 0;
}

void setup() {
    bigArduino.begin(9600);
    Serial.begin(9600);
    bigArduino.println("Starting init sequence");
    prepCrc();
    setjmp(restarter);
    setupSim();
    timestamp = millis();
    bigArduino.println("Init complete");
}

void get_input() {
  if (bigArduino.available() > 0) {
    char k = bigArduino.read();
    bigArduino.print("\nRead ");
    delay(500);
    bigArduino.println(k);
    delay(500);
    struct result *r = handle_char(k, &ps);
    if (r) {
      // bigArduino.println("Got a tag");
      if (strncmp(r->tag, "LV", 2) == 0) {
        if (*(r->content) == '0') {
          notErring = 0;
        } else notErring = 1; // always assume the worst
        return;
      }
      if (r->length + 5 < 16) {
        if (strncmp(r->tag, "LA", 2) == 0) {
          lat_len = r->length + 5;
          createProtocolMessage(lat_buffer, "LA", r->content, r->length);
          return;
        }
        if (strncmp(r->tag, "LO", 2) == 0) {
          lon_len = r->length + 5;
          createProtocolMessage(lon_buffer, "LO", r->content, r->length);
          return;
        }
      }
    }
  }
}

int c = 0;

void loop() {
  update_loc();
  get_input();
  if (c == 500) {
    c = 0;
    str_cache(arduinoPrint);
  }
  c++;
}

