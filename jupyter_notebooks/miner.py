from pynq import Overlay
from pynq import PL
from pynq import MMIO
import binascii

class Miner(object):

    IP_NAME = "bitcoin_miner_ip_0"

    def __init__(self, bitstream_path):
        ol = Overlay(bitstream_path)
        ol.download()
        phys_addr = PL.ip_dict[self.IP_NAME]['phys_addr']
        addr_range = PL.ip_dict[self.IP_NAME]['addr_range']
        self._mmio = MMIO(phys_addr, addr_range)

    def write_words(self, offset, data):
        for pos in range(0, len(data), 4):
            d = int.from_bytes(data[pos:pos+4], byteorder='big')
            self._mmio.write(offset + pos, d)

    def write_first_block_hash(self, hash):
        self.write_words(0x00, hash)

    def write_second_block(self, block):
        self.write_words(0x20, block)

    def write_target(self, target):
        self.write_words(0x30, target)

    def start(self):
        self._mmio.write(0x54,0x01)
        self._mmio.write(0x54,0x00)

    def wait_stop(self):
        while self._mmio.read(0x54) & 0x01:
            pass

    def is_found(self):
        return bool(self._mmio.read(0x54) & 0x02)

    def read_nonce(self):
        return self._mmio.read(0x58)
