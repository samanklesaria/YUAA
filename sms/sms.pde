#include <pt.h>
#include <Wire.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "Parser.h"

#define BUFFSIZE 100
char at_buffer[BUFFSIZE];

#define CMDLEN 30
char cmd[CMDLEN];

#define SERVERLOC "yuaa.kolmas.cz"
#define APN "wap.voicestream.com"
#define PREFIX "GET yuaa.kolmas.cz/store.php?data="

#define KILLSIGNAL "KILL"
#define LOCSIGNAL "LOC"
#define INFOSIGNAL "INFO"

#define LACTAG to_int('L'), to_int('C')
#define LATTAG to_int('L'), to_int('T')
#define LONTAG to_int('L'), to_int('N')
#define MCCTAG to_int('M'), to_int('C')
#define MNCTAG to_int('M'), to_int('N')
#define CIDTAG to_int('C'), to_int('I')
#define KILLTAG to_int('K'), to_int('L')

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

bool isErring() {
    get_info(to_int('K') -1, to_int('L') -1)->exists;
}

void setErring() {
    update_tag(KILLTAG, "", 0);
}

// this should be so for all the numbers we use. Don't just use my phone.
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
    
    Serial1.println("AT+CREG=2"); // actually, he returns the values too. can wait for +CREG:
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
    sprintf(cmd,"AT+CGACT=1,%1d", &con);
    Serial1.println(cmd);
    wait_for("OK");
    sprintf(cmd,"AT+SDATACONF=1,\"TCP\",\"%s\",80", host);
    Serial1.println(cmd);
    wait_for("OK");
    Serial1.println("AT+SDATASTART=1,1");
    wait_for("OK");
    Serial1.print("AT+SSTRSEND=1,\"");
}

void endServer() {
    Serial1.println("\"");
    wait_for("OK");
}

void endConnection(int con) {
    sprintf(cmd,"AT+SDATASTART=$1d,0", &con);
    Serial1.println(cmd);
}

void post_to_server() {
    Serial1.print(PREFIX);
    str_cache();
    Serial1.print("\r\n\r\n"); // really?
}

void update_loc() {
    store_mcc_mnc();
    store_lac_cid();
    if (isErring())
        makeCall();
    startServer(SERVERLOC, 1);
    post_to_server();
    endServer();
    wait_for("+STCPD");
    endConnection(1);
}

void handle_text() {
	Serial.println("Handling texts");
    wait_for("+CMT");
    read_from(cellAvailable, cellRead);
    if (strstr(at_buffer, KILLSIGNAL)) if (isErring()) {setErring(); return; }
    if (strstr(at_buffer, LOCSIGNAL)) { update_loc(); delay(1000); makeCall(); return; }
    if (strstr(at_buffer, INFOSIGNAL)) { delay(1000); makeCall(); return; }
}

void do_texts() {
    handle_text();
    delay(1000);
    Serial1.println("AT+CMGD=1,4");
    wait_for("OK");
}

static struct pt updater, texter;

static int text(struct pt *pt) {
  PT_BEGIN(pt);
  while(1) do_texts();
  PT_END(pt);
}

static int update(struct pt *pt) {
    PT_BEGIN(pt);
    static unsigned long timestamp = 0;
    while(1) {
        update_loc;
        PT_WAIT_UNTIL(pt, millis() - timestamp > 1000);
        timestamp = millis();
    }
    PT_END(pt);
}

// sending num bytes first shouldn't be necessary, but ah well
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
  Serial.println("I got something");
  while(0 < Wire.available()) // loop through all but the last
  {
    char c = Wire.receive(); // receive byte as a character
    handle_char(c);
  }
}

void setup() {
    PT_INIT(&updater);
    PT_INIT(&texter);
    
    Serial.begin(9600);
    initCrc8();
    Serial1.begin(9600);
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
    Wire.begin(42);
    Wire.onReceive(receiveEvent);
    Wire.onRequest(wireCache);
}

void loop() {
    update(&updater);
    text(&texter);
}
