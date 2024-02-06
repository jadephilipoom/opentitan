keccakf_piln = [
        10, 7,  11, 17, 18, 3, 5,  16, 8,  21, 24, 4,
        15, 23, 19, 13, 12, 2, 20, 14, 22, 9,  6,  1]

keccakf_rotc = [
        1,  3,  6,  10, 15, 21, 28, 36, 45, 55, 2,  14,
        27, 41, 56, 8,  25, 43, 62, 18, 39, 61, 20, 44
]


def gen_mem_to_state(state_start=0, mem_label="context", tmp_gpr="t0", mask=25, tmp=30):
    state = list(range(state_start, state_start + 25))
    # TODO: This causes OOB read, better fix this at some point
    print(f"addi {tmp_gpr}, zero, {tmp}")
    for i in range(6):
        print(f"bn.lid {tmp_gpr}, 0({mem_label}++)")
        for j in range(4):
            print(f"bn.and w{state[i * 4 + j]}, w{mask}, w{tmp} >> {j * 32}")
    # last separately
    print(f"bn.lid {tmp_gpr}, 0({mem_label}++)")
    print(f"bn.and w{state[24]}, w{mask}, w{tmp}")


def _ROTL64(in_reg, tmp_reg, amount, out_reg=-1):
    if out_reg == -1:
        out_reg = tmp_reg
    print(f"bn.rshi w{tmp_reg}, w{in_reg}, bn0 >> 64")
    print(f"bn.rshi w{out_reg}, w{in_reg}, w{tmp_reg} >> {256 - 64 + amount}")
    # TODO: Maybe mask


def gen_theta(state_start=0, bc_start=25, tmp=30):
    print("/* THETA */")
    state = list(range(state_start, state_start + 25)) 
    bc = list(range(bc_start, bc_start + 5))
    for i in range(5):
        print(f"bn.xor w{bc[i]}, w{bc[i]}, w{state[i + 5]}")
        for off in [10, 15, 20]:
            print(f"bn.xor w{bc[i]}, w{bc[i]}, w{state[i + off]}")

    for i in range(5):
        _ROTL64(bc[(i + 1) % 5], tmp, 1)
        print(f"bn.xor w{tmp}, w{bc[(i + 4) % 5]}, w{tmp}")
        for j in range(0, 25, 5):
            print(f"bn.xor w{state[j + i]}, w{state[j + i]}, w{tmp}")


def gen_rho_pi(state_start=0, bc_start=25, tmp=30):
    state = list(range(state_start, state_start + 25)) 
    bc = list(range(bc_start, bc_start + 5))
    print("/* RHO PI */")
    print(f"bn.mov w{tmp}, w{state[1]}")
    for i in range(0, 24):
        j = keccakf_piln[i]
        # bc[0] = st[j];
        print(f"bn.mov w{bc[0]}, w{state[j]}")
        # st[j] = ROTL64(t, keccakf_rotc[i]);
        _ROTL64(tmp, bc[1], keccakf_rotc[i], out_reg=state[j])  # TODO: Is bc[1] okay to overwrite?
        # t = bc[0];
        print(f"bn.mov w{tmp}, w{bc[0]}")


def gen_chi(state_start=0, bc_start=25, tmp=30):
    state = list(range(state_start, state_start + 25))
    bc = list(range(bc_start, bc_start + 5))
    print("/* CHI */")
    for j in range(0, 25, 5):
        for i in range(5):
            # bc[i] = st[j + i];
            print(f"bn.mov w{bc[i]}, w{state[j + i]}")
        for i in range(5):
            # st[j + i] ^= (~bc[(i + 1) % 5]) & bc[(i + 2) % 5];
            print(f"bn.not w{tmp}, w{bc[(i + 1) % 5]}")
            print(f"bn.and w{tmp}, w{tmp}, w{bc[(i + 2) % 5]}")
            print(f"bn.xor w{state[j + i]}, w{state[j + i]}, w{tmp}")


def gen_iota(round=0, state_start=0, tmp=30):
    state = list(range(state_start, state_start + 25))
    print("/* IOTA */")
    # Load round constant
    print("addi rc_addr, rc_addr, 32")  # RC is 64-bit
    print(f"bn.lid w{tmp}, {round*32}(rc_addr)")
    print(f"bn.xor w{state[0]}, w{state[0]}, w{tmp}")


def keccak_f():
    for r in range(24):
        gen_theta()
        gen_rho_pi()
        gen_chi()
        gen_iota()

# gen_mem_to_state()

gen_theta()
gen_rho_pi()
gen_chi()
gen_iota()