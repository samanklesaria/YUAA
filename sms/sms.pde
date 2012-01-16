#include <Wire.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <setjmp.h>
#include "Parser.h"

#define BUFFSIZE 100
char at_buffer[BUFFSIZE];
int buffidx;

#define DELAYTIME 10000

#define CMDLEN 30
char cmd[CMDLEN];

char number[12];

#define NUMLEN 220
char numbers[NUMLEN];
int numsidx = 0;

int mode = 0;
jmp_buf restarter;

#define SERVERLOC "yuaa.kolmas.cz"
#define APN "wap.voicestream.com"
#define PREFIX "GET /store.php?"
#define POSTFIX " HTTP/1.1\\r\\nHost: yuaa.kolmas.cz\\r\\n\\r\\n"

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
#define KILLTAG to_int('K'), to_int('L')


int cellAvailable() {
    Serial1.available();
}

char cellRead() {
    Serial1.read();
}

int serialAvailable() {
    Serial.available();
}

char serialRead() {
    Serial.read();
}

void wireSend(uint8_t *c, int i) {
    Wire.send(c, i);
}

void serialSend(uint8_t *c, int i) {
    Serial1.write(c, i);
}

void displaySend(uint8_t *c, int i) {
    Serial.write(c, i);
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
        read_from(cellAvailable, cellRead);
        Serial.print("Waiting with line ");
        Serial.println(at_buffer);
        if (strstr(at_buffer,a)) return;
        processor();
    }
}

void processor() {
        if (strstr(at_buffer,"ERROR")) {
            Serial.println("Could not proceed with operation");
            longjmp(restarter, 0);
        };
        if (strstr(at_buffer,"+CMT")) {
          Serial.println("Got a text");
          parseNumber();
          read_from(cellAvailable, cellRead);
          if (strstr(at_buffer, KILLSIGNAL)) if (isErring()) {setErring(); killCall(); }
          if (strstr(at_buffer, INFOSIGNAL)) { delay(1000); makeCall(); }
          if (strstr(at_buffer, ADDSIGNAL)) addNumber();
          Serial1.println("AT+CMGD=1,4");
          wait_for("OK");
        };
        if (strstr(at_buffer,"+SIND") && mode == 1) {
           Serial.println("Restarting");
           mode = 0;
           setupSim();
           longjmp(restarter, 0);
        };
        if (strstr(at_buffer, "+CREG")) {
              store_lac_cid();
              Serial.println("Done with Cregging");
        };
}

void wait_for_byte(char a) {
    Serial.println(a, BYTE);
    while (1) {
        if (Serial1.available() > 0) {
            char inc = Serial1.read();
            Serial.print("Waiting with char ");
            Serial.println(inc, BYTE);
            if (inc == a) return;
        }
    }
}

void passthrough() {
    while (1) {
        read_from(cellAvailable, cellRead);
        Serial.println(at_buffer);
    }
}

void printTag(int i, int j, void sender(uint8_t *c, int)) {
    if ((get_info(i,j))->exists) {
        data *d = get_info(i,j);
        char tag[3];
        tag[0] = to_char(i+1);
        tag[1] = to_char(j+1);
        tag[2] = '\0';
        char checksum = crc8(tag,0,2);
        checksum = crc8(d->content, checksum, d->length);
        sender((uint8_t *)tag,2);
        if (d->length > 0)
          sender((uint8_t*)(d->content), d->length);
        sender((uint8_t *)":",1);
        char message[2];
        sprintf(message, "%.2x", (unsigned char)checksum);
        sender((uint8_t *)message,2);
        free(message);
        free(d);
        free(tag);
    }
}

void str_cache() {
    int i;
    for (i=0; i < 23; i++) {
        int j;
        for (j=0; j < 23; j++) {
            if (!((i == to_int('I') -1 && j == to_int('M') - 1) || (i == to_int('M') -1 && j == to_int('S') - 1)))
              printTag(i,j, serialSend);
        }
    }
}

int isErring() {
    get_info(to_int('K') -1, to_int('L') -1)->exists;
}

void setErring() {
    update_tag(KILLTAG, "", 0);
}

void startCall(char *phn) {
    Serial1.print("AT+CMGS=\"");
    Serial1.write((uint8_t*)phn, 11);
    Serial1.print("\"\r");
    Serial.println("Sent the r");
    wait_for_byte('>');
}

void endCall() {
    Serial1.print(26, BYTE);
    Serial.println("Should be sending");
    wait_for("OK");
}

void makeCall () {
  int i;
  for (i = 0; i < numsidx; i += 10) {
    startCall(numbers + i);
    str_cache();
    endCall();
  }
}

void killCall() {
  int i;
  for (i = 0; i < numsidx; i += 10) {
    startCall(numbers + i);
    Serial1.print("Getting killed");
    endCall();
  }
}

void store_mcc_mnc() {
    Serial1.println("AT+COPS?");
    read_from(cellAvailable, cellRead);
    read_from(cellAvailable, cellRead);
    char *mcc_mnc = strchr(strchr(at_buffer,',') +1,',') + 1;
    update_tag(MCCTAG, mcc_mnc, 3);
    Serial.println("Mcc:");
    Serial.write((uint8_t*)mcc_mnc, 3);
    Serial.print("\r\n");
    update_tag(MNCTAG, mcc_mnc + 3, 2);
    Serial.println("Mnc:");
    Serial.write((uint8_t*)mcc_mnc + 3, 2);
    Serial.print("\r\n");
    wait_for("OK");
}

void store_lac_cid() {
    char *start = strchr(at_buffer, ',') + 1;
    Serial.print("String is ");
    Serial.println(start);
    char lacstr[6];
    long int lac;
    char cidstr[6];
    long int cid;
    sscanf(start,"0x%x,0x%X", &lac, &cid);
    Serial.print("Lac is ");
    Serial.println(lac);
    Serial.print("Cid is ");
    Serial.println(cid);
    sprintf(lacstr, "%d", lac);
    sprintf(cidstr, "%d", cid);
    Serial.print("LacString is ");
    Serial.println(lacstr);
    Serial.print("CidString is ");
    Serial.println(cidstr);
    update_tag(LACTAG, lacstr, strlen(lacstr));
    update_tag(CIDTAG, cidstr, strlen(cidstr));
}

void doServer() {
    Serial.println("Starting server");
    sprintf(cmd,"AT+CGDCONT=1,\"IP\",\"%s\"", APN);
    Serial1.println(cmd);
    wait_for("OK");
    Serial1.println("AT+CGACT=1,1");
    wait_for("OK");
    sprintf(cmd,"AT+SDATACONF=1,\"TCP\",\"%s\",80", SERVERLOC);
    Serial1.println(cmd);
    wait_for("OK");
    Serial.println("Starting data");
    Serial1.println("AT+SDATASTART=1,1");
    wait_for("OK");
    Serial.println("sending data");
    Serial1.print("AT+SDATASEND=1,");
    Serial1.println((int)(strlen(PREFIX) + info_size() + strlen(POSTFIX)));
    wait_for_byte('>');
    str_cache();
    Serial1.print(26, BYTE);
    wait_for("OK");
    Serial1.println("AT+SDATASTART=1,0");
    wait_for("OK");
}

static unsigned long timestamp = 0;

void update_loc() {
    int b = maybe_read_byte(cellAvailable, cellRead);
    if (b) {
       buffidx = 0;
       Serial.print("Main waiting with line ");
       Serial.println(at_buffer);
       setjmp(restarter);
       processor();
    }
    /*
    if (millis() - timestamp > DELAYTIME) {
      timestamp = millis();
      if (isErring()) {
        setjmp(restarter);
        makeCall();
      }
    }
    */
    // setjmp(restarter);
    // doServer();
}

void addNumber() {
  Serial.print("Adding number ");
  Serial.println(number);
  strcpy(numbers + numsidx, number);
  numsidx += 11;
  startCall(number);
  Serial1.print("Gotcha");
  endCall();
}

void wireCache() {
    Serial.println("Got wire");
    int16_t length = 0;
    data *lac = get_info(to_int('L') -1,to_int('C')-1);
    data *cid = get_info(to_int('M') -1,to_int('C')-1);
    data *kill = get_info(to_int('K') -1,to_int('L')-1);
    // needs to be converted from hex. GRR
    
    if (lac->exists)
        length += (lac->length + 5);
    if (cid->exists)
        length += (cid->length + 5);
    if (kill->exists)
        length += 5;
    Serial.println((char)(length>>8 & 0xFF));
    Wire.send((char)(length>>8 & 0xFF));
    Serial.println((char)(length & 0xFF));
    Wire.send((char)(length & 0xFF));
    printTag(to_int('L') -1, to_int('C')-1, wireSend);
    printTag(to_int('M') -1, to_int('C')-1, wireSend);
    printTag(to_int('K') -1, to_int('L')-1, wireSend);
}

void receiveEvent(int howMany)
{
  Serial.println("Receive wire");
  while(0 < Wire.available())
  {
    char c = Wire.receive();
    handle_char(c);
  }
}

void setupSim() {
    mode = 0;
    wait_for("+SIND: 4");
    Serial.println("Connected fine");
    Serial1.println("AT+CMGF=1");
    wait_for("OK");
    Serial1.println("AT+CMGD=1,4");
    wait_for("OK");
    
    // this should work, but sometimes doesn't
    // doesn't seem to matter
    
    // Serial1.println("AT+SBAND=7");
    // wait_for("OK");
    
    Serial1.println("AT+CNMI=3,3,0,0");
    wait_for("OK");
    Serial.println("Everything set up");
    mode = 1;
    
    store_mcc_mnc();
    Serial1.println("AT+CREG=2");
    wait_for("OK");
    Serial.println("Done setting sim up");
}

void setup() {
    Serial.begin(9600);
    initCrc8();
    Serial1.begin(9600);
    // Wire.begin(0x42);
    setupSim();
    buffidx = 0;
    
    wait_for("PIGS");
    // Serial.println("Done with setup");
    // int numsidx = 11;
    // strncpy(numbers, "16517477993", 11);
    
    // update_tag(LACTAG, "123",3);
    // update_tag(CIDTAG, "4567", 4);
    // Wire.onReceive(receiveEvent);
    // Wire.onRequest(wireCache);
}

void loop() {
  delay(1000);
  // update_loc();
}
