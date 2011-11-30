#include <string.h>
#include <Time.h>
#include <Wire.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <pt.h>
#include "../parser/Parser.c"

void str_cache() {
    int i;
    for (i=0; i < 23; i++) {
        int j;
        for (j=0; j < 23; j++) {
            if (craft_info[i][j]) {
                data *d = craft_info[i][j];
                char *tag = (char *)malloc(sizeof(char) * 3);
                tag[0] = to_char(i+1);
                tag[1] = to_char(j+1);
                tag[2] = '\0';
                char checksum = crc8(tag,0,2);
                checksum = crc8(d->content, checksum, d->length);
                Serial1.print(tag);
                Serial1.write((uint8_t*)(d->content), d->length);
                Serial1.print(':');
                char *message = (char *)malloc(sizeof(char) * 3);
                sprintf(message, "%.2x", (unsigned char)checksum);
                Serial1.print(message);
                free(message);
                free(d);
                free(tag);
            }
        }
    }
}

#define BUFFSIZE 100
char at_buffer[BUFFSIZE];

static bool erring = 0;

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

void startCall() {
    Serial1.print("AT+CMGS=\"16517477993\"");
    Serial1.print('\r');
    Serial.println("Sent the r");
    wait_for_byte('>');
}

void endCall() {
    Serial1.print(26, BYTE);
    Serial.println("Should be sending");
    wait_for("OK");
}

void makeCall () {
    startCall();
    str_cache();
    endCall();
}

void store_lat_lon() {
    char *lat = strstr("lat=\"",at_buffer) + 5;
    int lat_len = strchr(lat,'"') - 1 - lat;
    char *lon = strstr("lon=\"",lat) + 5;
    int lon_len = strchr(lon,'"') - 1 - lon;
    update_tag(LATTAG, lat, lat_len);
    update_tag(LONTAG, lon, lon_len);
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

void handle_text() {
	Serial.println("Handling texts");
    wait_for("+CMT");
    read_from(cellAvailable, cellRead);
    if (strstr(at_buffer, KILLSIGNAL)) if (!erring) {erring = 1; err_mode(); }
    if (strstr(at_buffer, LOCSIGNAL)) { update_loc(); delay(1000); makeCall(); }
    if (strstr(at_buffer, INFOSIGNAL)) { delay(1000); makeCall(); }
}

void do_texts() {
    handle_text();
    delay(1000);
    Serial1.println("AT+CMGD=1,4");
    wait_for("OK");
}

static struct pt waitThread, textThread;

static int text(struct pt *pt) {
  PT_BEGIN(pt);
  while(1) do_texts();
  PT_END(pt);
}

void blitzCalls() {
    static unsigned long timestamp = 0;
    while(1) {
        PT_WAIT_UNTIL(pt, millis() - timestamp > 60000); // will this work here?
        timestamp = millis();
        update_loc();
        delay(1000); // is there a thread version?
        makeCall();
    }  
}

static int wait(struct pt *pt) {
    PT_BEGIN(pt);
    while(1) {
        // i2c stuff here. find out what.
    }
    PT_END(pt);
}

static int text(struct pt *pt) {
    PT_BEGIN(pt);
    while(1) do_texts();
    PT_END(pt);
}

void err_mode() {
    erring = 1;
    Wire.beginTransmission();
    Wire.send(KILLSIGNAL);
    Wire.endTransmission();
    blitzCalls();
}

void setup() {
    PT_INIT(&waitThread);
    PT_INIT(&textThread);
    
    Serial.begin(9600);
    initCrc8();
    Serial1.begin(9600);
    Wire.begin();
    wait_for("+SIND: 4");
    Serial.println("Connected fine");
    Serial1.println("AT+CMGF=1");
    wait_for("OK");
    Serial1.println("AT+CMGD=1,4");
    wait_for("OK");
    
    // this should work, but sometimes doesn't
    /*
    Serial1.println("AT+SBAND=7");
    wait_for("OK");
    */
    
    // experimental stuff
    /*
    cell.println("AT+COPS=0,2");
    wait_for("OK");
    cell.println("AT+CREG=2");
    wait_for("OK");
    */
    
    Serial.println("Everything set up");
    Serial1.println("AT+CNMI=3,3,0,0");
    wait_for("OK");
}

void loop() {
    wait(&waitThread);
    text(&textThread);
}
