#!/usr/bin/env python3
# gen-vectors.py - writes the test vectors for the testbenches into sim/vectors/ using the "cryptography" package.

import os, random

# The cryptography package is the independent reference
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

# Output folder next to this script
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "vectors")
# Make sure it exists
os.makedirs(OUT, exist_ok=True)
# Fixed seed so the vectors never change between runs
rnd = random.Random(0xAE5128)

# This function encrypts bytes with AES-128-ECB
def ecb_enc(key, data):
    # Build the cipher and run it once
    e = Cipher(algorithms.AES(key), modes.ECB()).encryptor()
    # Return the cipher text
    return e.update(data) + e.finalize()

# This function decrypts bytes with AES-128-ECB
def ecb_dec(key, data):
    # Build the cipher and run it once
    d = Cipher(algorithms.AES(key), modes.ECB()).decryptor()
    # Return the plain text
    return d.update(data) + d.finalize()

# This function encrypts bytes with AES-128-CTR (128 bit big-endian counter)
def ctr(key, iv, data):
    # Build the cipher and run it once
    e = Cipher(algorithms.AES(key), modes.CTR(iv)).encryptor()
    # Return the output (same function encrypts and decrypts)
    return e.update(data) + e.finalize()

# This function writes bytes as one hex byte per line
def write_bytes(name, data):
    # Open the file
    with open(os.path.join(OUT, name), "w") as f:
        # One byte per line
        for b in data:
            f.write("%02x\n" % b)

# Published known answers: FIPS-197 C.1, FIPS-197 appendix B and NIST SP 800-38A F.1.1 / F.5.1
fips_key = bytes(range(16))
# FIPS-197 C.1 plain text
fips_pt = bytes.fromhex("00112233445566778899aabbccddeeff")
# FIPS-197 C.1 cipher text
fips_ct = bytes.fromhex("69c4e0d86a7b0430d8cdb78070b4c55a")
# The reference library must agree with the published value
assert ecb_enc(fips_key, fips_pt) == fips_ct
# FIPS-197 appendix B
appb_key = bytes.fromhex("2b7e151628aed2a6abf7158809cf4f3c")
# Appendix B plain text
appb_pt = bytes.fromhex("3243f6a8885a308d313198a2e0370734")
# Appendix B cipher text
appb_ct = bytes.fromhex("3925841d02dc09fbdc118597196a0b32")
# The reference library must agree with the published value
assert ecb_enc(appb_key, appb_pt) == appb_ct
# NIST SP 800-38A plain text blocks
nist_pt = bytes.fromhex("6bc1bee22e409f96e93d7e117393172a" "ae2d8a571e03ac9c9eb76fac45af8e51"
                        "30c81c46a35ce411e5fbc1191a0a52ef" "f69f2445df4f9b17ad2b417be66c3710")
# NIST ECB cipher text blocks
nist_ecb = bytes.fromhex("3ad77bb40d7a3660a89ecaf32466ef97" "f5d3d58503b9699de785895a96fdbaaf"
                         "43b1cd7f598ece23881b00e3ed030688" "7b0c785e27e8ad3f8223207104725dd4")
# The reference library must agree with the published values
assert ecb_enc(appb_key, nist_pt) == nist_ecb
# NIST CTR initial counter block
nist_iv = bytes.fromhex("f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff")
# NIST CTR cipher text blocks
nist_ctr = bytes.fromhex("874d6191b620e3261bef6864990db6ce" "9806f66b7970fdff8617187bb9fffdff"
                         "5ae4df3edbd5d35e5b4f09020db03eab" "1e031dda2fbe03d1792170a0f3009cee")
# The reference library must agree with the published values
assert ctr(appb_key, nist_iv, nist_pt) == nist_ctr

# ---- core vectors: lines of key / plain / cipher as 32 hex digits, byte 0 first
cases = [(fips_key, fips_pt), (appb_key, appb_pt)]
# Add the four NIST blocks
for i in range(4):
    cases.append((appb_key, nist_pt[16*i:16*i+16]))
# Edge keys and blocks
cases.append((bytes(16), bytes(16)))
# All ones
cases.append((b"\xff" * 16, b"\xff" * 16))
# Random cases
for _ in range(60):
    cases.append((bytes(rnd.randrange(256) for _ in range(16)), bytes(rnd.randrange(256) for _ in range(16))))
# Write the file
with open(os.path.join(OUT, "core.mem"), "w") as f:
    # Three lines per case
    for k, p in cases:
        f.write(k.hex() + "\n" + p.hex() + "\n" + ecb_enc(k, p).hex() + "\n")
# Remember the case count for the testbench
print("core cases:", len(cases))

# ---- top level vectors (one hex byte per line)
# Key 1 is the NIST key
write_bytes("key1.mem", appb_key)
# ECB plain text: four NIST blocks plus two random blocks
ecb_pt = nist_pt + bytes(rnd.randrange(256) for _ in range(32))
# ECB plain text file
write_bytes("ecb-pt.mem", ecb_pt)
# ECB cipher text file
write_bytes("ecb-ct.mem", ecb_enc(appb_key, ecb_pt))
# CTR initial counter block
write_bytes("iv.mem", nist_iv)
# CTR plain text: the first 40 bytes of the NIST text (a partial third block)
ctr_pt = nist_pt[:40]
# CTR plain text file
write_bytes("ctr-pt.mem", ctr_pt)
# CTR cipher text file (equals the first 40 bytes of the NIST cipher text)
write_bytes("ctr-ct.mem", ctr(appb_key, nist_iv, ctr_pt))
# The second command continues the counter: plain text for two more blocks, 32 bytes
ctr_pt2 = nist_pt[40:64] + bytes(rnd.randrange(256) for _ in range(8))
# Expected output continues the same CTR stream but restarts on a block boundary (counter advanced by 3 blocks in total)
# so the reference encrypts 3 blocks of zeros to advance the counter, then takes the next stream bytes
adv = ctr(appb_key, nist_iv, bytes(48))
# Build a CTR object again from the start and discard the first 48 bytes
e = Cipher(algorithms.AES(appb_key), modes.CTR(nist_iv)).encryptor()
# Discard the keystream already used (3 blocks: 2 full and the partial third counts as a whole block)
e.update(bytes(48))
# Encrypt the second command data
ctr_ct2 = e.update(ctr_pt2) + e.finalize()
# Second CTR plain text file
write_bytes("ctr-pt2.mem", ctr_pt2)
# Second CTR cipher text file
write_bytes("ctr-ct2.mem", ctr_ct2)
# Second key for the re-key test
key2 = bytes(rnd.randrange(256) for _ in range(16))
# Second key file
write_bytes("key2.mem", key2)
# One block for the second key
pt2 = bytes(rnd.randrange(256) for _ in range(16))
# Plain text for key 2
write_bytes("pt2.mem", pt2)
# Cipher text for key 2
write_bytes("ct2.mem", ecb_enc(key2, pt2))
# Report
print("top vectors written to", OUT)
