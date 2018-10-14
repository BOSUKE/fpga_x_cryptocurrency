#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <openssl/sha.h>

void fill_buf_with_rand_num(uint32_t *buf, size_t count)
{
  for (size_t i = 0; i < count; i++) buf[i] = rand();
}

void sha256_calc_h(const void* src, size_t length, uint32_t *h)
{
  SHA256_CTX c;
  SHA256_Init(&c);
  SHA256_Update(&c, src, length);
  for (size_t i = 0; i < 8; i++) h[i] = htonl(c.h[i]);
}

void hexdump(const void* p, size_t length)
{
  const uint8_t *pb = p;
  for (size_t i = 0; i < length; i++) printf("%02x", *pb++);
}

int main(int argc, char *argv[])
{
  if (argc < 3) {
    printf("Usage: %s count seed\n", argv[0]);
    return 0;
  }
  int count = atoi(argv[1]);
  int seed = atoi(argv[2]);
  srand(seed);
  for (int i = 0; i < count; i++) {
    uint32_t message[16];
    uint32_t h[8];
    fill_buf_with_rand_num(message, 16);
    sha256_calc_h(message, sizeof(message), h);
    printf("512'h"); hexdump(message, sizeof(message)); printf(";\n");
    printf("256'h"); hexdump(h, sizeof(h)); printf(";\n");
  }
  return 0;
}
