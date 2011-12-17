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

#define DELAYTIME 10000

#define CMDLEN 30
char cmd[CMDLEN];

char number[11];

#define NUMLEN 200
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

void read_from(int (*avail)(), char (*reader)()) {
    int buffidx = 0;
    while (1) {
        if ((*avail)() > 0) {
            char c = (*reader)();
            if (c == '\n') continue;
            if (c == '\r') {
                at_buffer[buffidx] = '\0';
                return;
            }
            if (!(buffidx == BUFFSIZE - 1)) at_buffer[buffidx++] = c;
        }
    }
}

void parseNumber() {
  char *a = strchr(at_buffer, ',') + 1;
  strncpy(number, a, min(10, strlen(at_buffer)));
} 

void wait_for(char *a) {
    while (1) {
        read_from(cellAvailable, cellRead);
        Serial.print("Waiting with line ");
        Serial.println(at_buffer);
        if (strstr(at_buffer,a)) return;
        if (strstr(at_buffer,"ERROR")) {
            Serial.println("Could not proceed with operation");
            return;
        };
        if (strstr(at_buffer,"+CMT")) {
          parseNumber();
          read_from(cellAvailable, cellRead);
          if (strstr(a, KILLSIGNAL)) if (isErring()) {setErring(); killCall(); return; }
          if (strstr(a, INFOSIGNAL)) { delay(1000); makeCall(); return; }
          if (strstr(a, ADDSIGNAL)) { addNumber(); return; }
          Serial1.println("AT+CMGD=1,4");
          wait_for("OK");
        };
        if (strstr(at_buffer,"+SIND: 1") && mode == 1) {
           mode = 0;
           setupSim();
           longjmp(restarter, 0);
        };
    }
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
        char *tag = (char *)malloc(sizeof(char) * 3);
        tag[0] = to_char(i+1);
        tag[1] = to_char(j+1);
        tag[2] = '\0';
        char checksum = crc8(tag,0,2);
        checksum = crc8(d->content, checksum, d->length);
        sender((uint8_t *)tag,2);
        sender((uint8_t*)(d->content), d->length);
        sender((uint8_t *)":",1);
        char *message = (char *)malloc(sizeof(char) * 2);
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

// this should be so for all the numbers we use. Don't just use my phone.
void startCall(char *phn) {
    Serial1.print("AT+CMGS=\"");
    Serial1.write((uint8_t*)phn, 10);
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
    char *lac;
    char *cid;
    char *end_cid;
    
    Serial1.println("AT+CREG=2");
    wait_for("OK");
    Serial1.println("AT+CREG?");
    read_from(cellAvailable, cellRead);
    read_from(cellAvailable, cellRead);
    lac = strchr(at_buffer, ',') + 1;
    cid = strchr(lac, ',') + 1;
    Serial.print("lac/ cid: ");
    Serial.println(lac);
    update_tag(LACTAG, lac, cid - lac - 1);
    update_tag(CIDTAG, cid, strlen(cid));
    wait_for("OK");
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
    store_mcc_mnc();
    store_lac_cid();
    setjmp(restarter);
    if (millis() - timestamp > DELAYTIME) {
      timestamp = millis();
      if (isErring())
        makeCall();
    }
    doServer();
}

void addNumber() {
  strcpy(numbers + numsidx, number);
  numsidx += 10;
}

void wireCache() {
    int16_t address = 0;
    data *lac = get_info(to_int('L') -1,to_int('C')-1);
    data *cid = get_info(to_int('M') -1,to_int('C')-1);
    data *kill = get_info(to_int('K') -1,to_int('L')-1);
    
    if (lac->exists)
        address += (lac->length + 5);
    if (cid->exists)
        address += (cid->length + 5);
    if (kill->exists)
        address += 5;
    Wire.send((char)(address>>8));
    Wire.send((char)(address));     
    printTag(to_int('L') -1, to_int('C')-1, wireSend);
    printTag(to_int('M') -1, to_int('C')-1, wireSend);
    printTag(to_int('K') -1, to_int('L')-1, wireSend);
}

void receiveEvent(int howMany)
{
  while(0 < Wire.available())
  {
    char c = Wire.receive();
    handle_char(c);
  }
}

void setupSim() {
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
}

void setup() {
    Serial.begin(9600);
    initCrc8();
    Serial1.begin(9600);
    Wire.begin(42);
    Wire.onReceive(receiveEvent);
    Wire.onRequest(wireCache);
}

void loop() {
  update_loc();
  delay(1000);
}
