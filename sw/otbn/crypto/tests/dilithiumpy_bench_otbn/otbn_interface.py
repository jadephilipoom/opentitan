import struct
from typing import List, Tuple
from hw.ip.otbn.util.otbn_sim_py import run_sim

def key_pair_otbn(zeta: bytes, is_base=True) -> Tuple[bytes, bytes]:
    is_base_str = "_base" if is_base else ""
    # skip the first 8 bytes (=model, op_state)
    _, raw_dmem, stat_data = run_sim(f"key_pair{is_base_str}_dilithium_test", [(43840, zeta)]) #43840

    pk = raw_dmem[40000:40000 + 1312]
    sk = raw_dmem[40000 + 1312:40000 + 1312 + 2528]

    return pk, sk, stat_data


def verify_otbn(pk_bytes: bytes, m: bytes, sig_bytes: bytes, is_base=True) -> int:
    is_base_str = "_base" if is_base else ""
    # skip the first 8 bytes (=model, op_state)
    # account for alignment of message
    pk_addr = 40000
    sig_addr = pk_addr + 1312
    m_addr = (sig_addr + 2416)
    m_addr = (m_addr + (m_addr % 32))  # align
    m_len_addr = m_addr + 9 * 4 + 3300
    m_len_bytes = len(m).to_bytes(4, "little")
    regs, _, stat_data = run_sim(f"verify{is_base_str}_dilithium_test", [(pk_addr, pk_bytes),
                                                (sig_addr, sig_bytes),
                                                (m_addr, m),
                                                (m_len_addr, m_len_bytes)])

    print(regs)

    # a0 is 0 on success, -1 on fail
    return regs["x10"] == 0, stat_data


def sign_otbn(sk_bytes: bytes, m: bytes, is_base=True) -> int:
    is_base_str = "_base" if is_base else ""
    # skip the first 8 bytes (=model, op_state)
    # account for alignment of message
    sk_addr = 52800
    sig_addr = sk_addr + 2528
    m_addr = sig_addr + 2420
    from math import ceil
    m_addr = int(ceil(m_addr / 32) * 32)  # align
    m_len_addr = m_addr + 9 * 4 + 3300
    m_len_bytes = len(m).to_bytes(4, "little")
    print(f"m_len_addr {m_len_addr}")
    print(f"m_len_bytes {m_len_bytes.hex()}")
    regs, raw_dmem, stat_data = run_sim(f"sign{is_base_str}_dilithium_test", [(sk_addr, sk_bytes),
                                                (m_addr, m),
                                                (m_len_addr, m_len_bytes)])
    sig = raw_dmem[sig_addr:sig_addr+2420]

    print(regs)

    # sig, 0, siglen
    return sig, regs["x10"], regs["x11"], stat_data
