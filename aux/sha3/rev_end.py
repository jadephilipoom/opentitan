def rev_end(input, chunksize):
    BYTE_LEN = 2
    chunksize *= 2
    chunks = [input[i:i+chunksize] for i in range(0, len(input), chunksize)]
    new_chunks = []
    for chunk in chunks:
        sc = [chunk[i:i+BYTE_LEN] for i in range(0, len(chunk), BYTE_LEN)]
        new_chunks.append("".join(reversed(sc)))
    return new_chunks

def print_asm(chunks):
    for chunk in chunks:
        print(f".dword 0x{chunk}")


def print_exp(chunks):
    print(f"0x{''.join([c.lower() for c in chunks])}")


chunks = rev_end("E35780EB9799AD4C77535D4DDB683CF33EF367715327CF4C4A58ED9CBDCDD486F669F80189D549A9364FA82A51A52654EC721BB3AAB95DCEB4A86A6AFA93826DB923517E928F33E3FBA850D45660EF83B9876ACCAFA2A9987A254B137C6E140A21691E1069413848", 8)
print_asm(chunks)
chunks = rev_end("D1C0FA85C8D183BEFF99AD9D752B263E286B477F79F0710B010317017397813344B99DAF3BB7B1BC5E8D722BAC85943A", 4)
print_exp(chunks)