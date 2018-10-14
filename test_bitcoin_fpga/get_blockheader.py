import requests
import json
import binascii

def get_best_block_hash():
    url = "https://blockexplorer.com/api/status?q=getBestBlockHash"
    r = requests.get(url)
    return r.json()["bestblockhash"]

def get_block(hash):
    url = "https://blockexplorer.com/api/block/" + hash
    r = requests.get(url)
    return r.json()

def get_raw_block_header(hash):
    url = "https://blockexplorer.com/api/rawblock/" + hash
    r = requests.get(url)
    return r.json()["rawblock"][:160]

if __name__ == '__main__':
    best_hash = get_best_block_hash()
    block = get_block(best_hash)

    print(f"Hash: 256'h{best_hash}")
    print(f"Nonce: 32'h{block['nonce']:08x}")

    raw_block_header = get_raw_block_header(best_hash)
    print(f"BlockHeader[64:] 128'h{raw_block_header[64*2:]}")

    block_header_bin = binascii.a2b_hex(raw_block_header)
    with open("block_header.bin", "wb") as f:
        f.write(block_header_bin)

    
