#include <string.h>
#include <Time.h>
#include <Wire.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "../parser/Parser.c"

// should handle errors too

// I think we can cut mcc/mnc updating and just do it once after initionalization
// I think we can stop polling for lac/ cid and just wait for it in handle_texts

#define BUFFSIZE 100
char at_buffer[BUFFSIZE];

#define CMDLEN 30
char cmd[CMDLEN];

char req[] = "GET cell/get?key=f146d401108de36297356ce9d026c8c6&mnc=00&mcc=000&lac=000&cellid=000\r\nHost: www.opencellid.org\r\n\r\n";

#define SERVERLOC "myserver.kolmaz.cz"
#define APN "myapn"

#define KILLSIGNAL "KILL"
#define LOCSIGNAL "LOC"
#define INFOSIGNAL "INFO"

#define LACTAG to_int('L'), to_int('C')
#define LATTAG to_int('L'), to_int('T')
#define LONTAG to_int('L'), to_int('N')
#define MCCTAG to_int('M'), to_int('C')
#define MNCTAG to_int('M'), to_int('N')
#define CIDTAG to_int('C'), to_int('I')

#define DOWNTIME 60000
time_t lastCheck = 0;

#define DELAYTIME 60000

char incoming_char=0; 

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

void passthrough() {
    while (1) {
        read_from(cellAvailable, cellRead);
        Serial.println(at_buffer);
    }
}

void wait_for(char *a) {
    while (1) {
        read_from(cellAvailable, cellRead);
        Serial.print("Waiting with line ");
        Serial.println(at_buffer);
        if (strstr(at_buffer,a)) return;
        if (strstr(at_buffer,"ERROR")) {
            Serial.println("Could not proceed with operation");
            passthrough();
            return;
        };
    }
}

void startCall() {
    Serial1.println("AT+CMGS=\"16517477993\"");
    wait_for(">");
}

void endCall() {
    Serial1.print(26,BYTE);
}

void makeCall() {
    startCall();
    Serial1.print("done with that");
    Serial1.print(0x1A, BYTE);
    wait_for("OK");
}

void store_mcc_mnc() {
    Serial1.println("AT+COPS?");
    read_from(cellAvailable, cellRead);
    read_from(cellAvailable, cellRead);
    char *mcc_mnc = strchr(strchr(at_buffer,',') +1,',') + 1;
    Serial.print("mcc/mnc: ");
    Serial.println(mcc_mnc);
    update_tag(MCCTAG, mcc_mnc, 3);
    update_tag(MNCTAG, mcc_mnc + 3, 2);
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
    update_tag(LACTAG, lac, cid - lac);
    update_tag(CIDTAG, cid, strlen(cid));
    wait_for("OK");
    Serial1.println("AT+CREG=0");
}

void startServer(char *host, int con) {
    sprintf(cmd,"AT+CGDCONT=1,\"IP\",\"%s\"", APN);
    Serial1.println(cmd);
    wait_for("OK");
    sprintf(cmd,"AT+CGACT=%1d,1", &con);
    Serial1.println(cmd);
    wait_for("OK");
    sprintf(cmd,"AT+SDATACONF=1,\"TCP\",\"%s\",80", host);
    Serial1.println(cmd);
    wait_for("OK");
    Serial1.println("AT+SDATASTART=1,1");
    Serial1.print("AT+SSTRSEND=1,\"");
}

void endServer() {
    Serial1.println("\"");
    wait_for("OK");
}

void endConnection(int con) {
    wait_for("+STCP");
    sprintf(cmd,"AT+SDATASTART=$1d,0", &con);
    Serial1.println(cmd);
}

void update_loc() {
    store_mcc_mnc();
    store_lac_cid();
    /*
    startServer(SERVERLOC, 2);
    Serial1.print(req);
    endServer();
    wait_for("+STCPD:1");
    Serial1.println("AT+SDATAREAD=1");
    read_from(cellAvailable, cellRead);
    store_lat_lon();
    endConnection(2);
    */
}

// should we ignore all SIND messages?
// should we build waiting for SIND 4 status into reading if a SIND appears

void handle_text() {
    Serial.println("Handling texts");
    wait_for("+CMT");
    Serial.print("Received: ");
    Serial.println(at_buffer);
    // while (strchr(at_buffer, '+'))
    read_from(cellAvailable, cellRead);
    Serial.print("Received: ");
    Serial.println(at_buffer);
    if (strstr(at_buffer, INFOSIGNAL)) { delay(10000); makeCall(); }
    // if (strstr(at_buffer, KILLSIGNAL)) { Serial.println("Got killed!"); }
    // if (strstr(at_buffer, LOCSIGNAL)) { update_loc(); delay(1000); makeCall(); }
    Serial.println("Done handling a text");
}

void setup() {
    // initCrc8();
    Serial.begin(9600);
    Serial1.begin(9600);
    wait_for("+SIND: 4");
    Serial.println("Connected fine");
    Serial1.println("AT+CMGF=1");
    wait_for("OK");
    Serial1.println("AT+SBAND=7");
    wait_for("OK");
    Serial1.println("AT+CMGD=1,4");
    wait_for("OK");
    Serial1.println("AT+CNMI=3,3,0,0");
    wait_for("OK");
    Serial.println("Everything set up");
}

void handle_texts() {
    int i;
    for (i=0; i < 3; i++) {
        Serial1.println("AT+CMGF=1");
        delay (1000);
        Serial1.print("AT+CMGS=");
        Serial1.print(34,BYTE);
        Serial1.print("16517477993");
        Serial1.println(34,BYTE);
        delay (1000);
        Serial1.print("Ha ");
        Serial1.print(i);
        Serial1.print(" ");
        Serial1.println(26,BYTE);
         delay (3000);
        
    }
}

void loop() {
    handle_texts();
    passthrough();
    // Serial1.println("AT+CMGD=1,4");
    // wait_for("OK");
    // Serial.println("Done Deleting");
}
