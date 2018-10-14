#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <openssl/sha.h>

void sha256_calc_h(const void* src, size_t length, uint32_t *h) {
  SHA256_CTX c;
  SHA256_Init(&c);
  SHA256_Update(&c, src, length);
  for (size_t i = 0; i < 8; i++) h[i] = htonl(c.h[i]);
}

void hexdump(const void* p, size_t length) {
  const uint8_t *pb = p;
  for (size_t i = 0; i < length; i++) printf("%02x", *pb++);
}

int main(void) {
  uint8_t buf[512];
  uint32_t h[8];
  size_t length = fread(buf, 1, sizeof(buf), stdin);
  sha256_calc_h(buf, length, h);
  printf("256'h"); hexdump(h, sizeof(h)); printf(";\n");
  return 0;
}
