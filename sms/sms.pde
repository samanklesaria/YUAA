#include <Wire.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <setjmp.h>
#include "Parser.h"

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
#define DELAYTIME 20000
#define CMDLEN 30
#define NUMLEN 220

// THIS IS THE REAL VERSION

int introduced = 0;

char at_buffer[BUFFSIZE];
int buffidx;
char cmd[CMDLEN];
char number[12];
char numbers[45] = "1651747799312033470933";
int numsidx = 22;

int inSetup = 0;
int isErring = 0;

char mcc_buffer[15];
int mcc_len;
char lac_buffer[32];
int lac_len;
char lat_buffer[16];
int lon_len;
char lon_buffer[16];
int lat_len;

char log_buffer[12];

void str_cache(void printer(char *c)) {
  printer(mcc_buffer);
  printer(lac_buffer);
  printer(lat_buffer);
  printer(lon_buffer);
  printer(log_buffer);
}

jmp_buf restarter;
jmp_buf init_restarter;

parserState ps;

static unsigned long timestamp = 0;
static unsigned long timeoutstamp = 0;

int cellAvailable() {
    Serial.available();
}

char cellRead() {
    Serial.read();
}

void serialPrint(char *c) {
  Serial.print(c);
}

void wirePrint(char *c) {
  Wire.send(c);
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
        if (strstr(at_buffer,a)) return;
        if (processor() == 1) return;
    }
}

int processor() {
        createProtocolMessage(log_buffer, "CS", "1", 1);
        if (strstr(at_buffer,"ERROR")) {
            delay(1000);
            if (inSetup) {
              longjmp(init_restarter, 0);
            }
            setupSim();
            longjmp(restarter, 0);
        };
        if (strstr(at_buffer,"+CMT")) {
          parseNumber();
          read_from(cellAvailable, cellRead);
          if (strstr(at_buffer, KILLSIGNAL)) if (!isErring) {isErring = 1; killCall(); }
          if (strstr(at_buffer, INFOSIGNAL)) { delay(1000); makeCall(); }
          if (strstr(at_buffer, ADDSIGNAL)) addNumber();
          Serial.println("AT+CMGD=1,4");
          wait_for("OK");
          return 0;
        };
        if (strstr(at_buffer, "+SIND: 4")) {
          setupSim();
          longjmp(restarter, 0);
        }
        if (strstr(at_buffer, "+CREG")) {
              store_lac_cid();
              return 1;
        };
        return 0;
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

void passthrough() {
    while (1) {
        read_from(cellAvailable, cellRead);
    }
}

void startCall(char *phn) {
    createProtocolMessage(log_buffer, "CS", "2", 1);
    Serial.print("AT+CMGS=\"");
    Serial.write((uint8_t*)phn, 11);
    Serial.print("\"\r");
    wait_for_byte('>');
}

void endCall() {
    Serial.print(26, BYTE);
    wait_for("OK");
}

void makeCall () {
  delay(1000);
  int i;
  for (i = 0; i < numsidx; i += 11) {
    startCall(numbers + i);
    str_cache(serialPrint);
    endCall();
  }
}

void killCall() {
  int i;
  for (i = 0; i < numsidx; i += 10) {
    startCall(numbers + i);
    endCall();
  }
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
      createProtocolMessage(mcc_buffer, "MC", mcc_mnc, 3);
      createProtocolMessage(mcc_buffer + 8, "MN", mcc_mnc + 3, 2);
      *(mcc_buffer + 14) = '\0';
      mcc_len = 15;
      wait_for("OK");
      break;
    }
    wait_for("OK");
  }
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
    createProtocolMessage(lac_buffer, "LC", lacstr, laclen);
    createProtocolMessage(lac_buffer + laclen + 5, "CI", cidstr, cidlen);
    *(lac_buffer + laclen + cidlen + 10) = '\0';
}

void addNumber() {
  strcpy(numbers + numsidx, number);
  numsidx += 11;
  startCall(number);
  Serial.print("Gotcha");
  endCall();
}

void update_loc() {
    createProtocolMessage(log_buffer, "CS", "3", 1);
    int b = maybe_read_byte(cellAvailable, cellRead);
    if (b) {
       buffidx = 0;
       setjmp(restarter);
       int a = processor();
       if (a) return;
    }
    if (millis() - timestamp > DELAYTIME) {
       Serial.println("UPDATED");
      timestamp = millis();
      if (isErring) {
        createProtocolMessage(log_buffer, "CS", "5", 1);
        setjmp(restarter);
        makeCall();
      }
    }
}

void wireCache() {
    // int length = mcc_len + lac_len + lat_len + lon_len;
    // Wire.send((char)(length>>8 & 0xFF));
    // Wire.send((char)(length & 0xFF));
    if (!introduced)
      Wire.send("I am here");
    introduced = 1;
    str_cache(wirePrint);
}

void receiveEvent(int howMany)
{
  while(1 < Wire.available())
  {
    char c = Wire.receive();
    result *r = handle_char(c, &ps);
    if (r) {
      if (strncmp(r->tag, "LV", 2) == 0) {
        if (*(r->content) == '0')
          isErring = 0;
        else isErring = 1; // always assume the worst
        continue;
      }
      if (r->length + 5 < 16) {
        if (strncmp(r->tag, "LA", 2) == 0) {
          lat_len = r->length + 5;
          createProtocolMessage(lat_buffer, "LA", r->content, r->length);
        }
        if (strncmp(r->tag, "LO", 2) == 0) {
          lon_len = r->length + 5;
          createProtocolMessage(lon_buffer, "LO", r->content, r->length);
        }
      }
    }
  }
  Wire.receive();    // receive byte as an integer
}

void setupSim() {
    inSetup = 1;
    setjmp(init_restarter);
    Serial.println("AT+CMGF=1");
    wait_for("OK");
    setjmp(init_restarter);
    Serial.println("AT+CMGD=1,4");
    wait_for("OK");
    
    // Serial1.println("AT+SBAND=7");
    // wait_for("OK");
    
    setjmp(init_restarter);
    store_mcc_mnc();
    
    setjmp(init_restarter);
    Serial.println("AT+CNMI=3,3,0,0");
    wait_for("OK");
    
    setjmp(init_restarter);
    Serial.println("AT+CREG=2");
    wait_for("OK");
    createProtocolMessage(log_buffer, "CS", "4", 1);
    inSetup = 0;
}

void setup() {
    Wire.begin(4);
    Serial.begin(9600);
    Wire.onReceive(receiveEvent);
    Wire.onRequest(wireCache);
    prepCrc();
    setjmp(restarter);
    setupSim();
    timestamp = millis();
}

void loop() {
  update_loc();
}

// need a timeout
