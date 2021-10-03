
## XOR the entire array of bytes, byte by byte
def bytewise_xor(bytes1, bytes2):
    result_bytes = bytearray()

    for (a, b) in zip(bytes1, bytes2):
        result_bytes.append(a ^ b)

    return result_bytes

## Function to compute the parity file
def compute_parity(file):
    filesize = len(file)
    half = int(filesize/2)

    share1 = file[0:half]
    share2 = file[half:]

    return bytewise_xor(share1, share2)