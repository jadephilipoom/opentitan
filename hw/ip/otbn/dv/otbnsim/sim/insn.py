# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

from typing import Dict, Iterator, Optional
import sys
import struct

from .constants import ErrBits
from .flags import FlagReg
from .isa import (OTBNInsn, RV32RegReg, RV32RegImm,
                  RV32ImmShift, insn_for_mnemonic, logical_byte_shift,
                  bit_shift,
                  extract_quarter_word, extract_sub_word)
from .state import OTBNState
sys.path.append('../../util')
import otbn_sim_py_shared as shared
from dilithiumpy.shake_wrapper import Shake


def eprint(text):
    print(text, file=sys.stderr)


class ADD(RV32RegReg):
    insn = insn_for_mnemonic('add', 3)

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_unsigned()
        val2 = state.gprs.get_reg(self.grs2).read_unsigned()
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        result = (val1 + val2) & ((1 << 32) - 1)
        state.gprs.get_reg(self.grd).write_unsigned(result)


class ADDI(RV32RegImm):
    insn = insn_for_mnemonic('addi', 3)

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_unsigned()
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        result = (val1 + self.imm) & ((1 << 32) - 1)
        state.gprs.get_reg(self.grd).write_unsigned(result)


class LUI(OTBNInsn):
    insn = insn_for_mnemonic('lui', 2)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.grd = op_vals['grd']
        self.imm = op_vals['imm']

    def execute(self, state: OTBNState) -> None:
        state.gprs.get_reg(self.grd).write_unsigned(self.imm << 12)


class SUB(RV32RegReg):
    insn = insn_for_mnemonic('sub', 3)

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_unsigned()
        val2 = state.gprs.get_reg(self.grs2).read_unsigned()
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        result = (val1 - val2) & ((1 << 32) - 1)
        state.gprs.get_reg(self.grd).write_unsigned(result)


class SLL(RV32RegReg):
    insn = insn_for_mnemonic('sll', 3)

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_unsigned()
        val2 = state.gprs.get_reg(self.grs2).read_unsigned() & 0x1f
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        result = (val1 << val2) & ((1 << 32) - 1)
        state.gprs.get_reg(self.grd).write_unsigned(result)


class SLLI(RV32ImmShift):
    insn = insn_for_mnemonic('slli', 3)

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_unsigned()
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        result = (val1 << self.shamt) & ((1 << 32) - 1)
        state.gprs.get_reg(self.grd).write_unsigned(result)


class SRL(RV32RegReg):
    insn = insn_for_mnemonic('srl', 3)

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_unsigned()
        val2 = state.gprs.get_reg(self.grs2).read_unsigned() & 0x1f
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        result = val1 >> val2
        state.gprs.get_reg(self.grd).write_unsigned(result)


class SRLI(RV32ImmShift):
    insn = insn_for_mnemonic('srli', 3)

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_unsigned()
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        result = val1 >> self.shamt
        state.gprs.get_reg(self.grd).write_unsigned(result)


class SRA(RV32RegReg):
    insn = insn_for_mnemonic('sra', 3)

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_signed()
        val2 = state.gprs.get_reg(self.grs2).read_unsigned() & 0x1f
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        result = val1 >> val2
        state.gprs.get_reg(self.grd).write_signed(result)


class SRAI(RV32ImmShift):
    insn = insn_for_mnemonic('srai', 3)

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_signed()
        val2 = self.shamt
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        result = val1 >> val2
        state.gprs.get_reg(self.grd).write_signed(result)


class AND(RV32RegReg):
    insn = insn_for_mnemonic('and', 3)

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_unsigned()
        val2 = state.gprs.get_reg(self.grs2).read_unsigned()
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        result = val1 & val2
        state.gprs.get_reg(self.grd).write_unsigned(result)


class ANDI(RV32RegImm):
    insn = insn_for_mnemonic('andi', 3)

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_unsigned()
        val2 = self.to_2s_complement(self.imm)
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        result = val1 & val2
        state.gprs.get_reg(self.grd).write_unsigned(result)


class OR(RV32RegReg):
    insn = insn_for_mnemonic('or', 3)

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_unsigned()
        val2 = state.gprs.get_reg(self.grs2).read_unsigned()
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        result = val1 | val2
        state.gprs.get_reg(self.grd).write_unsigned(result)


class ORI(RV32RegImm):
    insn = insn_for_mnemonic('ori', 3)

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_unsigned()
        val2 = self.to_2s_complement(self.imm)
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        result = val1 | val2
        state.gprs.get_reg(self.grd).write_unsigned(result)


class XOR(RV32RegReg):
    insn = insn_for_mnemonic('xor', 3)

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_unsigned()
        val2 = state.gprs.get_reg(self.grs2).read_unsigned()
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        result = val1 ^ val2
        state.gprs.get_reg(self.grd).write_unsigned(result)


class XORI(RV32RegImm):
    insn = insn_for_mnemonic('xori', 3)

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_unsigned()
        val2 = self.to_2s_complement(self.imm)
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        result = val1 ^ val2
        state.gprs.get_reg(self.grd).write_unsigned(result)


class LW(OTBNInsn):
    insn = insn_for_mnemonic('lw', 3)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.grd = op_vals['grd']
        self.offset = op_vals['offset']
        self.grs1 = op_vals['grs1']

    def execute(self, state: OTBNState) -> Optional[Iterator[None]]:
        # LW executes over two cycles. On the first cycle, we read the base
        # address, compute the load address and check it for correctness, then
        # perform the load itself, returning the result.
        #
        # On the second cycle, we write the result to the destination register.

        base = state.gprs.get_reg(self.grs1).read_unsigned()
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        addr = (base + self.offset) & ((1 << 32) - 1)

        if not state.dmem.is_valid_32b_addr(addr):
            state.stop_at_end_of_cycle(ErrBits.BAD_DATA_ADDR)
            return

        result = state.dmem.load_u32(addr)

        # Stall for a single cycle for memory to respond
        yield

        if result is None:
            state.stop_at_end_of_cycle(ErrBits.DMEM_INTG_VIOLATION)
            return

        state.gprs.get_reg(self.grd).write_unsigned(result)


class SW(OTBNInsn):
    insn = insn_for_mnemonic('sw', 3)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.grs2 = op_vals['grs2']
        self.offset = op_vals['offset']
        self.grs1 = op_vals['grs1']

    def execute(self, state: OTBNState) -> None:
        base = state.gprs.get_reg(self.grs1).read_unsigned()
        addr = (base + self.offset) & ((1 << 32) - 1)
        value = state.gprs.get_reg(self.grs2).read_unsigned()
        bad_grs1 = state.gprs.call_stack_err and (self.grs1 == 1)

        saw_err = False

        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            saw_err = True

        if not state.dmem.is_valid_32b_addr(addr) and not bad_grs1:
            state.stop_at_end_of_cycle(ErrBits.BAD_DATA_ADDR)
            saw_err = True

        if saw_err:
            return

        state.dmem.store_u32(addr, value)


class BEQ(OTBNInsn):
    insn = insn_for_mnemonic('beq', 3)
    affects_control = True
    has_fetch_stall = True

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.grs1 = op_vals['grs1']
        self.grs2 = op_vals['grs2']
        self.offset = op_vals['offset']

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_unsigned()
        val2 = state.gprs.get_reg(self.grs2).read_unsigned()
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        tgt_pc = self.offset & ((1 << 32) - 1)
        if val1 == val2:
            if not state.is_pc_valid(tgt_pc):
                state.stop_at_end_of_cycle(ErrBits.BAD_INSN_ADDR)
            else:
                state.set_next_pc(tgt_pc)


class BNE(OTBNInsn):
    insn = insn_for_mnemonic('bne', 3)
    affects_control = True
    has_fetch_stall = True

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.grs1 = op_vals['grs1']
        self.grs2 = op_vals['grs2']
        self.offset = op_vals['offset']

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_unsigned()
        val2 = state.gprs.get_reg(self.grs2).read_unsigned()

        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        tgt_pc = self.offset & ((1 << 32) - 1)
        if val1 != val2:
            if not state.is_pc_valid(tgt_pc):
                state.stop_at_end_of_cycle(ErrBits.BAD_INSN_ADDR)
            else:
                state.set_next_pc(tgt_pc)


class JAL(OTBNInsn):
    insn = insn_for_mnemonic('jal', 2)
    affects_control = True
    has_fetch_stall = True

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.grd = op_vals['grd']
        self.offset = op_vals['offset']

    def execute(self, state: OTBNState) -> None:
        mask32 = ((1 << 32) - 1)
        link_pc = (state.pc + 4) & mask32
        state.gprs.get_reg(self.grd).write_unsigned(link_pc)

        next_pc = self.offset & mask32
        if not state.is_pc_valid(next_pc):
            state.stop_at_end_of_cycle(ErrBits.BAD_INSN_ADDR)
        else:
            state.set_next_pc(next_pc)


class JALR(OTBNInsn):
    insn = insn_for_mnemonic('jalr', 3)
    affects_control = True
    has_fetch_stall = True

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.grd = op_vals['grd']
        self.grs1 = op_vals['grs1']
        self.offset = op_vals['offset']

    def execute(self, state: OTBNState) -> None:
        val1 = state.gprs.get_reg(self.grs1).read_unsigned()
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        mask32 = ((1 << 32) - 1)
        link_pc = (state.pc + 4) & mask32

        state.gprs.get_reg(self.grd).write_unsigned(link_pc)

        next_pc = (val1 + self.offset) & mask32
        if not state.is_pc_valid(next_pc):
            state.stop_at_end_of_cycle(ErrBits.BAD_INSN_ADDR)
        else:
            state.set_next_pc(next_pc)


class CSRRS(OTBNInsn):
    insn = insn_for_mnemonic('csrrs', 3)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.grd = op_vals['grd']
        self.csr = op_vals['csr']
        self.grs1 = op_vals['grs1']

    def execute(self, state: OTBNState) -> Optional[Iterator[None]]:
        if not state.csrs.check_idx(self.csr):
            # Invalid CSR index. Stop with an illegal instruction error.
            state.stop_at_end_of_cycle(ErrBits.ILLEGAL_INSN)
            return

        bits_to_set = state.gprs.get_reg(self.grs1).read_unsigned()
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        if self.csr == 0xfc0:
            # A read from RND. If a RND value is not available, request_value()
            # initiates or continues an EDN request and returns False. If a RND
            # value is available, it returns True.
            while not state.wsrs.RND.request_value():
                # There's a pending EDN request. Stall for a cycle.
                yield

        # At this point, the CSR is ready. Read, update and write back to grs1.
        old_val = state.read_csr(self.csr)
        new_val = old_val | bits_to_set
        state.gprs.get_reg(self.grd).write_unsigned(old_val)
        if self.grs1 != 0:
            state.write_csr(self.csr, new_val)


class CSRRW(OTBNInsn):
    insn = insn_for_mnemonic('csrrw', 3)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.grd = op_vals['grd']
        self.csr = op_vals['csr']
        self.grs1 = op_vals['grs1']

    def execute(self, state: OTBNState) -> Optional[Iterator[None]]:
        if not state.csrs.check_idx(self.csr):
            # Invalid CSR index. Stop with an illegal instruction error.
            state.stop_at_end_of_cycle(ErrBits.ILLEGAL_INSN)
            return

        new_val = state.gprs.get_reg(self.grs1).read_unsigned()
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        if self.csr == 0xfc0 and self.grd != 0:
            # A read from RND. If a RND value is not available, request_value()
            # initiates or continues an EDN request and returns False. If a RND
            # value is available, it returns True.
            while not state.wsrs.RND.request_value():
                # There's a pending EDN request. Stall for a cycle.
                yield

        # At this point, the CSR is either ready or unneeded. Read it if
        # necessary and write to grd, then overwrite with new_val.

        if self.grd != 0:
            old_val = state.read_csr(self.csr)
            state.gprs.get_reg(self.grd).write_unsigned(old_val)

        state.write_csr(self.csr, new_val)


class ECALL(OTBNInsn):
    insn = insn_for_mnemonic('ecall', 0)

    def execute(self, state: OTBNState) -> None:
        # Set INTR_STATE.done and STATUS, reflecting the fact we've stopped.
        state.stop_at_end_of_cycle(err_bits=0)


class LOOP(OTBNInsn):
    insn = insn_for_mnemonic('loop', 2)
    affects_control = True

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.grs = op_vals['grs']
        self.bodysize = op_vals['bodysize']

    def execute(self, state: OTBNState) -> None:
        num_iters = state.gprs.get_reg(self.grs).read_unsigned()
        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            return

        if num_iters == 0:
            state.stop_at_end_of_cycle(ErrBits.LOOP)
        else:
            state.loop_start(num_iters, self.bodysize)


class LOOPI(OTBNInsn):
    insn = insn_for_mnemonic('loopi', 2)
    affects_control = True

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.iterations = op_vals['iterations']
        self.bodysize = op_vals['bodysize']

    def execute(self, state: OTBNState) -> None:
        if self.iterations == 0:
            state.stop_at_end_of_cycle(ErrBits.LOOP)
        else:
            state.loop_start(self.iterations, self.bodysize)


class SHAKESTART(OTBNInsn):
    insn = insn_for_mnemonic('shake_start', 2)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.op_state = op_vals['grs1']
        self.mode = op_vals['grs2']

    def execute(self, state: OTBNState) -> None:
        eprint("SHAKESTART")
        op_state = state.gprs.get_reg(self.op_state).read_unsigned()
        mode = state.gprs.get_reg(self.mode).read_unsigned()

        if not state.dmem.is_valid_32b_addr(mode) and not state.dmem.is_valid_32b_addr(op_state):
            state.stop_at_end_of_cycle(ErrBits.BAD_DATA_ADDR)
            return

        op_state = state.dmem.load_u32(op_state)
        mode = state.dmem.load_u32(mode)

        from hashlib import shake_256, shake_128
        if mode == 0:
            shared.SHAKE_INSTANCE = Shake(shake_256, 136)
        elif mode == 1:
            shared.SHAKE_INSTANCE = Shake(shake_128, 168)
        else:
            raise ValueError(f"Unsupported mode {mode}")

        # TODO: Initialize something


class SHAKEABSORB(OTBNInsn):
    insn = insn_for_mnemonic('shake_absorb', 3)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.op_state = op_vals['grs1']
        self.buf = op_vals['grs2']
        self.buflen = op_vals['grs3']

    def execute(self, state: OTBNState) -> None:
        eprint("SHAKEABSORB")
        op_state = state.gprs.get_reg(self.op_state).read_unsigned()
        buf = state.gprs.get_reg(self.buf).read_unsigned()
        buflen = state.gprs.get_reg(self.buflen).read_unsigned()

        if not state.dmem.is_valid_32b_addr(buf) and not state.dmem.is_valid_32b_addr(op_state):
            state.stop_at_end_of_cycle(ErrBits.BAD_DATA_ADDR)
            return

        op_state = state.dmem.load_u32(op_state)

        in_words = []
        for w in range(buflen // 4):
            in_words.append(state.dmem.load_u32(buf + w * 4))
        eprint(f"buflen {buflen}")
        in_bytes = struct.pack("<" + "I" * len(in_words), *in_words)
        # it is required for the buffer to be of a size that is a multiple by 4
        # (such that there will be no OOB read), but buflen may still be
        # non-divisible by 4 for reading with byte accuracy
        rest_bytes = buflen % 4
        if buflen % 4 != 0:
            # raise ValueError("Length not a multiple of word size")
            word_part = state.dmem.load_u32(buf + (buflen // 4) * 4)
            word_part &= (2**(rest_bytes * 8) - 1)
            in_bytes += (word_part).to_bytes(rest_bytes, byteorder='little')
        eprint("in_bytes " + in_bytes.hex())
        shared.SHAKE_INSTANCE.absorb(in_bytes)


class SHAKESQUEEZE(OTBNInsn):
    insn = insn_for_mnemonic('shake_squeeze', 3)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.op_state = op_vals['grs1']
        self.buf = op_vals['grs2']
        self.buflen = op_vals['grs3']

    def execute(self, state: OTBNState) -> None:
        eprint("SHAKESQUEEZE")
        import struct
        op_state = state.gprs.get_reg(self.op_state).read_unsigned()
        buf = state.gprs.get_reg(self.buf).read_unsigned()
        buflen = state.gprs.get_reg(self.buflen).read_unsigned()

        if not state.dmem.is_valid_32b_addr(buf) and not state.dmem.is_valid_32b_addr(op_state):
            state.stop_at_end_of_cycle(ErrBits.BAD_DATA_ADDR)
            return

        if buflen % 4 != 0:
            raise ValueError("Length not a multiple of word size")

        op_state = state.dmem.load_u32(op_state)

        out_bytes = shared.SHAKE_INSTANCE.read(buflen)

        ctr = 0
        for w in struct.unpack("<" + "I" * (buflen // 4), out_bytes):
            state.dmem.store_u32(buf + ctr * 4, w)
            ctr += 1


class BNADD(OTBNInsn):
    insn = insn_for_mnemonic('bn.add', 6)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs1 = op_vals['wrs1']
        self.wrs2 = op_vals['wrs2']
        self.shift_type = op_vals['shift_type']
        self.shift_bytes = op_vals['shift_bits'] // 8
        self.flag_group = op_vals['flag_group']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()
        b_shifted = logical_byte_shift(b, self.shift_type, self.shift_bytes)

        full_result = a + b_shifted
        mask256 = (1 << 256) - 1
        masked_result = full_result & mask256
        carry_flag = bool((full_result >> 256) & 1)
        flags = FlagReg.mlz_for_result(carry_flag, masked_result)

        state.wdrs.get_reg(self.wrd).write_unsigned(masked_result)
        state.set_flags(self.flag_group, flags)


class BNADDC(OTBNInsn):
    insn = insn_for_mnemonic('bn.addc', 6)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs1 = op_vals['wrs1']
        self.wrs2 = op_vals['wrs2']
        self.shift_type = op_vals['shift_type']
        self.shift_bytes = op_vals['shift_bits'] // 8
        self.flag_group = op_vals['flag_group']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()
        b_shifted = logical_byte_shift(b, self.shift_type, self.shift_bytes)

        carry = int(state.csrs.flags[self.flag_group].C)
        full_result = a + b_shifted + carry
        mask256 = (1 << 256) - 1
        masked_result = full_result & mask256
        carry_flag = bool((full_result >> 256) & 1)
        flags = FlagReg.mlz_for_result(carry_flag, masked_result)

        state.wdrs.get_reg(self.wrd).write_unsigned(masked_result)
        state.set_flags(self.flag_group, flags)


class BNADDI(OTBNInsn):
    insn = insn_for_mnemonic('bn.addi', 4)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs = op_vals['wrs']
        self.imm = op_vals['imm']
        self.flag_group = op_vals['flag_group']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs).read_unsigned()
        b = self.imm

        full_result = a + b
        mask256 = (1 << 256) - 1
        masked_result = full_result & mask256
        carry_flag = bool((full_result >> 256) & 1)
        flags = FlagReg.mlz_for_result(carry_flag, masked_result)

        state.wdrs.get_reg(self.wrd).write_unsigned(masked_result)
        state.set_flags(self.flag_group, flags)


class BNADDM(OTBNInsn):
    insn = insn_for_mnemonic('bn.addm', 6)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs1 = op_vals['wrs1']
        self.wrs2 = op_vals['wrs2']
        self.vec = op_vals['vec']
        self.type = op_vals['type']
        self.nored = op_vals['nored']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()
        mod_val = state.wsrs.MOD.read_unsigned()

        if not self.vec:
            result = a + b

            if result >= mod_val and not self.nored:
                result -= mod_val
        else:
            size = 32 if self.type == 0 else 16

            result = 0

            for i in range(256 // size, -1, -1):
                ai = OTBNInsn.from_2s_complement(extract_sub_word(a, size, i))
                bi = OTBNInsn.from_2s_complement(extract_sub_word(b, size, i))
                resulti = ai + bi
                if resulti >= mod_val and not self.nored:
                    resulti -= mod_val
                elif resulti < 0 and not self.nored:
                    resulti += mod_val
                result = (result << size) | (OTBNInsn.to_2s_complement(resulti, size) & ((1 << size) - 1))

        result = result & ((1 << 256) - 1)
        state.wdrs.get_reg(self.wrd).write_unsigned(result)


class BNMULMV(OTBNInsn):
    insn = insn_for_mnemonic('bn.mulmv', 6)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs1 = op_vals['wrs1']
        self.wrs2 = op_vals['wrs2']
        self.type = op_vals['type']
        self.lane = op_vals['lane']
        self.nored = op_vals['nored']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()
        mod_val = state.wsrs.MOD.read_unsigned()
        size = None
        if (self.type % 2) == 0:
            size = 32
        else:
            size = 16
        result = 0

        # Extract the lane
        if self.type >= 2:
            bi = OTBNInsn.from_2s_complement(extract_sub_word(b, size, self.lane))

        for i in range(256 // size, -1, -1):
            ai = OTBNInsn.from_2s_complement(extract_sub_word(a, size, i))
            if self.type < 2:
                bi = OTBNInsn.from_2s_complement(extract_sub_word(b, size, i))

            resulti = (ai * bi)  # TODO: match to hw implementation

            if not self.nored:  # TODO: add mask incase of nored
                resulti = resulti % mod_val

            result = (result << size) | (OTBNInsn.to_2s_complement(resulti, size) & ((1 << size) - 1))

        result = result & ((1 << 256) - 1)
        state.wdrs.get_reg(self.wrd).write_unsigned(result)


class BNMULQACC(OTBNInsn):
    insn = insn_for_mnemonic('bn.mulqacc', 6)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.zero_acc = op_vals['zero_acc']
        self.wrs1 = op_vals['wrs1']
        self.wrs1_qwsel = op_vals['wrs1_qwsel']
        self.wrs2 = op_vals['wrs2']
        self.wrs2_qwsel = op_vals['wrs2_qwsel']
        self.acc_shift_imm = op_vals['acc_shift_imm']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()

        a_qw = extract_quarter_word(a, self.wrs1_qwsel)
        b_qw = extract_quarter_word(b, self.wrs2_qwsel)

        mul_res = a_qw * b_qw

        acc = state.wsrs.ACC.read_unsigned()
        if self.zero_acc:
            acc = 0

        acc += (mul_res << self.acc_shift_imm)

        truncated = acc & ((1 << 256) - 1)
        state.wsrs.ACC.write_unsigned(truncated)


class BNMULQACCWO(OTBNInsn):
    insn = insn_for_mnemonic('bn.mulqacc.wo', 8)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.zero_acc = op_vals['zero_acc']
        self.wrd = op_vals['wrd']
        self.wrs1 = op_vals['wrs1']
        self.wrs1_qwsel = op_vals['wrs1_qwsel']
        self.wrs2 = op_vals['wrs2']
        self.wrs2_qwsel = op_vals['wrs2_qwsel']
        self.acc_shift_imm = op_vals['acc_shift_imm']
        self.flag_group = op_vals['flag_group']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()

        a_qw = extract_quarter_word(a, self.wrs1_qwsel)
        b_qw = extract_quarter_word(b, self.wrs2_qwsel)

        mul_res = a_qw * b_qw

        acc = state.wsrs.ACC.read_unsigned()
        if self.zero_acc:
            acc = 0

        acc += (mul_res << self.acc_shift_imm)

        truncated = acc & ((1 << 256) - 1)
        state.wdrs.get_reg(self.wrd).write_unsigned(truncated)
        state.wsrs.ACC.write_unsigned(truncated)
        state.set_mlz_flags(self.flag_group, truncated)


class BNMULQACCSO(OTBNInsn):
    insn = insn_for_mnemonic('bn.mulqacc.so', 9)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.zero_acc = op_vals['zero_acc']
        self.wrd = op_vals['wrd']
        self.wrd_hwsel = op_vals['wrd_hwsel']
        self.wrs1 = op_vals['wrs1']
        self.wrs1_qwsel = op_vals['wrs1_qwsel']
        self.wrs2 = op_vals['wrs2']
        self.wrs2_qwsel = op_vals['wrs2_qwsel']
        self.acc_shift_imm = op_vals['acc_shift_imm']
        self.flag_group = op_vals['flag_group']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()

        a_qw = extract_quarter_word(a, self.wrs1_qwsel)
        b_qw = extract_quarter_word(b, self.wrs2_qwsel)

        mul_res = a_qw * b_qw

        acc = state.wsrs.ACC.read_unsigned()
        if self.zero_acc:
            acc = 0

        acc += (mul_res << self.acc_shift_imm)
        truncated = acc & ((1 << 256) - 1)

        # Split the result into low and high parts
        lo_part = truncated & ((1 << 128) - 1)
        hi_part = truncated >> 128

        # Shift out the low part of the result
        hw_shift = 128 * self.wrd_hwsel
        hw_mask = ((1 << 128) - 1) << hw_shift
        old_wrd = state.wdrs.get_reg(self.wrd).read_unsigned()
        new_wrd = (old_wrd & ~hw_mask) | (lo_part << hw_shift)
        state.wdrs.get_reg(self.wrd).write_unsigned(new_wrd)

        # Write back the high part of the result
        state.wsrs.ACC.write_unsigned(hi_part)

        old_flags = state.csrs.flags[self.flag_group]
        if self.wrd_hwsel:
            new_flags = FlagReg(C=old_flags.C,
                                M=bool((lo_part >> 127) & 1),
                                L=old_flags.L,
                                Z=old_flags.Z and lo_part == 0)
        else:
            new_flags = FlagReg(C=old_flags.C,
                                M=old_flags.M,
                                L=bool(lo_part & 1),
                                Z=lo_part == 0)
        state.set_flags(self.flag_group, new_flags)


class BNSUB(OTBNInsn):
    insn = insn_for_mnemonic('bn.sub', 6)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs1 = op_vals['wrs1']
        self.wrs2 = op_vals['wrs2']
        self.shift_type = op_vals['shift_type']
        self.shift_bytes = op_vals['shift_bits'] // 8
        self.flag_group = op_vals['flag_group']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()
        b_shifted = logical_byte_shift(b, self.shift_type, self.shift_bytes)

        full_result = a - b_shifted
        mask256 = (1 << 256) - 1
        masked_result = full_result & mask256
        carry_flag = bool((full_result >> 256) & 1)
        flags = FlagReg.mlz_for_result(carry_flag, masked_result)

        state.wdrs.get_reg(self.wrd).write_unsigned(masked_result)
        state.set_flags(self.flag_group, flags)


class BNSUBB(OTBNInsn):
    insn = insn_for_mnemonic('bn.subb', 6)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs1 = op_vals['wrs1']
        self.wrs2 = op_vals['wrs2']
        self.shift_type = op_vals['shift_type']
        self.shift_bytes = op_vals['shift_bits'] // 8
        self.flag_group = op_vals['flag_group']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()
        b_shifted = logical_byte_shift(b, self.shift_type, self.shift_bytes)
        borrow = int(state.csrs.flags[self.flag_group].C)

        full_result = a - b_shifted - borrow
        mask256 = (1 << 256) - 1
        masked_result = full_result & mask256
        carry_flag = bool((full_result >> 256) & 1)
        flags = FlagReg.mlz_for_result(carry_flag, masked_result)

        state.wdrs.get_reg(self.wrd).write_unsigned(masked_result)
        state.set_flags(self.flag_group, flags)


class BNSUBI(OTBNInsn):
    insn = insn_for_mnemonic('bn.subi', 4)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs = op_vals['wrs']
        self.imm = op_vals['imm']
        self.flag_group = op_vals['flag_group']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs).read_unsigned()
        b = self.imm

        full_result = a - b
        mask256 = (1 << 256) - 1
        masked_result = full_result & mask256
        carry_flag = bool((full_result >> 256) & 1)
        flags = FlagReg.mlz_for_result(carry_flag, masked_result)

        state.wdrs.get_reg(self.wrd).write_unsigned(masked_result)
        state.set_flags(self.flag_group, flags)


class BNSUBM(OTBNInsn):
    insn = insn_for_mnemonic('bn.subm', 6)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs1 = op_vals['wrs1']
        self.wrs2 = op_vals['wrs2']
        self.vec = op_vals['vec']
        self.type = op_vals['type']
        self.nored = op_vals['nored']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()
        mod_val = state.wsrs.MOD.read_unsigned()

        if not self.vec:
            result = a - b
            if result < 0 and not self.nored:
                result += mod_val
        else:
            size = 32 if self.type == 0 else 16

            result = 0

            for i in range(256 // size, -1, -1):
                ai = OTBNInsn.from_2s_complement(extract_sub_word(a, size, i))
                bi = OTBNInsn.from_2s_complement(extract_sub_word(b, size, i))
                resulti = ai - bi

                if resulti < 0 and not self.nored:
                    resulti += mod_val
                elif resulti >= mod_val and not self.nored:
                    resulti -= mod_val
                result = (result << size) | (OTBNInsn.to_2s_complement(resulti, size) & ((1 << size) - 1))

        result = result & ((1 << 256) - 1)
        state.wdrs.get_reg(self.wrd).write_unsigned(result)


class BNAND(OTBNInsn):
    insn = insn_for_mnemonic('bn.and', 6)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs1 = op_vals['wrs1']
        self.wrs2 = op_vals['wrs2']
        self.shift_type = op_vals['shift_type']
        self.shift_bytes = op_vals['shift_bits'] // 8
        self.flag_group = op_vals['flag_group']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()
        b_shifted = logical_byte_shift(b, self.shift_type, self.shift_bytes)

        result = a & b_shifted
        state.wdrs.get_reg(self.wrd).write_unsigned(result)
        state.set_mlz_flags(self.flag_group, result)


class BNANDV(OTBNInsn):
    insn = insn_for_mnemonic('bn.andv', 7)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs1 = op_vals['wrs1']
        self.wrs2 = op_vals['wrs2']
        self.type = op_vals['type']
        self.shift_type = op_vals['shift_type']
        self.shift_bits = op_vals['shift_bits']
        self.shift_arith = op_vals['shift_arith']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()

        size = 32 if self.type == 0 else 16

        result = 0

        for i in range(256 // size, -1, -1):
            ai = extract_sub_word(a, size, i)
            bi = extract_sub_word(b, size, i)
            if self.shift_arith:
                bi_shifted = OTBNInsn.to_2s_complement(bit_shift(
                    OTBNInsn.from_2s_complement(bi), self.shift_type,
                    self.shift_bits, size))
            else:
                bi_shifted = bit_shift(bi, self.shift_type, self.shift_bits, size)

            resulti = ai & bi_shifted

            result = (result << size) | (resulti & ((1 << size) - 1))

        state.wdrs.get_reg(self.wrd).write_unsigned(result)


class BNORV(OTBNInsn):
    insn = insn_for_mnemonic('bn.orv', 7)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs1 = op_vals['wrs1']
        self.wrs2 = op_vals['wrs2']
        self.type = op_vals['type']
        self.shift_type = op_vals['shift_type']
        self.shift_bits = op_vals['shift_bits']
        self.shift_arith = op_vals['shift_arith']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()

        size = 32 if self.type == 0 else 16

        result = 0

        for i in range((256 - size) // size, -1, -1):
            ai = extract_sub_word(a, size, i)
            bi = extract_sub_word(b, size, i)
            if self.shift_arith:
                bi_shifted = OTBNInsn.to_2s_complement(bit_shift(
                    OTBNInsn.from_2s_complement(bi), self.shift_type,
                    self.shift_bits, size))
            else:
                bi_shifted = bit_shift(bi, self.shift_type, self.shift_bits, size)

            resulti = ai | bi_shifted

            result = (result << size) | (resulti & ((1 << size) - 1))

        state.wdrs.get_reg(self.wrd).write_unsigned(result)


class BNOR(OTBNInsn):
    insn = insn_for_mnemonic('bn.or', 6)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs1 = op_vals['wrs1']
        self.wrs2 = op_vals['wrs2']
        self.shift_type = op_vals['shift_type']
        self.shift_bytes = op_vals['shift_bits'] // 8
        self.flag_group = op_vals['flag_group']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()
        b_shifted = logical_byte_shift(b, self.shift_type, self.shift_bytes)

        result = a | b_shifted
        state.wdrs.get_reg(self.wrd).write_unsigned(result)
        state.set_mlz_flags(self.flag_group, result)


class BNNOT(OTBNInsn):
    insn = insn_for_mnemonic('bn.not', 5)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs = op_vals['wrs']
        self.shift_type = op_vals['shift_type']
        self.shift_bytes = op_vals['shift_bits'] // 8
        self.flag_group = op_vals['flag_group']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs).read_unsigned()
        a_shifted = logical_byte_shift(a, self.shift_type, self.shift_bytes)

        result = a_shifted ^ ((1 << 256) - 1)
        state.wdrs.get_reg(self.wrd).write_unsigned(result)
        state.set_mlz_flags(self.flag_group, result)


class BNXOR(OTBNInsn):
    insn = insn_for_mnemonic('bn.xor', 6)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs1 = op_vals['wrs1']
        self.wrs2 = op_vals['wrs2']
        self.shift_type = op_vals['shift_type']
        self.shift_bytes = op_vals['shift_bits'] // 8
        self.flag_group = op_vals['flag_group']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()
        b_shifted = logical_byte_shift(b, self.shift_type, self.shift_bytes)

        result = a ^ b_shifted
        state.wdrs.get_reg(self.wrd).write_unsigned(result)
        state.set_mlz_flags(self.flag_group, result)


class BNRSHI(OTBNInsn):
    insn = insn_for_mnemonic('bn.rshi', 4)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs1 = op_vals['wrs1']
        self.wrs2 = op_vals['wrs2']
        self.imm = op_vals['imm']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()

        result = (((a << 256) | b) >> self.imm) & ((1 << 256) - 1)
        state.wdrs.get_reg(self.wrd).write_unsigned(result)


class BNSEL(OTBNInsn):
    insn = insn_for_mnemonic('bn.sel', 5)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs1 = op_vals['wrs1']
        self.wrs2 = op_vals['wrs2']
        self.flag_group = op_vals['flag_group']
        self.flag = op_vals['flag']

    def execute(self, state: OTBNState) -> None:
        flag_is_set = state.csrs.flags[self.flag_group].get_by_idx(self.flag)
        wrs = self.wrs1 if flag_is_set else self.wrs2
        value = state.wdrs.get_reg(wrs).read_unsigned()
        state.wdrs.get_reg(self.wrd).write_unsigned(value)


class BNCMP(OTBNInsn):
    insn = insn_for_mnemonic('bn.cmp', 5)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrs1 = op_vals['wrs1']
        self.wrs2 = op_vals['wrs2']
        self.shift_type = op_vals['shift_type']
        self.shift_bytes = op_vals['shift_bits'] // 8
        self.flag_group = op_vals['flag_group']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()
        b_shifted = logical_byte_shift(b, self.shift_type, self.shift_bytes)

        full_result = a - b_shifted
        mask256 = (1 << 256) - 1
        masked_result = full_result & mask256
        carry_flag = bool((full_result >> 256) & 1)
        flags = FlagReg.mlz_for_result(carry_flag, masked_result)

        state.set_flags(self.flag_group, flags)


class BNCMPB(OTBNInsn):
    insn = insn_for_mnemonic('bn.cmpb', 5)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrs1 = op_vals['wrs1']
        self.wrs2 = op_vals['wrs2']
        self.shift_type = op_vals['shift_type']
        self.shift_bytes = op_vals['shift_bits'] // 8
        self.flag_group = op_vals['flag_group']

    def execute(self, state: OTBNState) -> None:
        a = state.wdrs.get_reg(self.wrs1).read_unsigned()
        b = state.wdrs.get_reg(self.wrs2).read_unsigned()
        b_shifted = logical_byte_shift(b, self.shift_type, self.shift_bytes)
        borrow = int(state.csrs.flags[self.flag_group].C)

        full_result = a - b_shifted - borrow
        mask256 = (1 << 256) - 1
        masked_result = full_result & mask256
        carry_flag = bool((full_result >> 256) & 1)
        flags = FlagReg.mlz_for_result(carry_flag, masked_result)

        state.set_flags(self.flag_group, flags)


class BNLID(OTBNInsn):
    insn = insn_for_mnemonic('bn.lid', 5)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.grd = op_vals['grd']
        self.grd_inc = op_vals['grd_inc']
        self.offset = op_vals['offset']
        self.grs1 = op_vals['grs1']
        self.grs1_inc = op_vals['grs1_inc']

    def execute(self, state: OTBNState) -> Optional[Iterator[None]]:
        # BN.LID executes over two cycles. On the first cycle, we read the base
        # address, compute the load address and check it for correctness,
        # increment any GPRs, then perform the load itself. On the second
        # cycle, update the WDR with the result.

        if self.grs1_inc and self.grd_inc:
            state.stop_at_end_of_cycle(ErrBits.ILLEGAL_INSN)
            return

        grs1_val = state.gprs.get_reg(self.grs1).read_unsigned()
        addr = (grs1_val + self.offset) & ((1 << 32) - 1)
        grd_val = state.gprs.get_reg(self.grd).read_unsigned()

        bad_grs1 = state.gprs.call_stack_err and (self.grs1 == 1)
        bad_grd = state.gprs.call_stack_err and (self.grd == 1)

        saw_err = False

        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            saw_err = True

        if grd_val > 31 and not bad_grd:
            state.stop_at_end_of_cycle(ErrBits.ILLEGAL_INSN)
            saw_err = True

        if not state.dmem.is_valid_256b_addr(addr) and not bad_grs1:
            state.stop_at_end_of_cycle(ErrBits.BAD_DATA_ADDR)
            saw_err = True

        if saw_err:
            return

        wrd = grd_val & 0x1f
        value = state.dmem.load_u256(addr)

        if self.grd_inc:
            new_grd_val = grd_val + 1
            state.gprs.get_reg(self.grd).write_unsigned(new_grd_val)

        if self.grs1_inc:
            new_grs1_val = (grs1_val + 32) & ((1 << 32) - 1)
            state.gprs.get_reg(self.grs1).write_unsigned(new_grs1_val)

        # Stall for a single cycle for memory to respond
        yield

        if value is None:
            state.stop_at_end_of_cycle(ErrBits.DMEM_INTG_VIOLATION)
            return

        state.wdrs.get_reg(wrd).write_unsigned(value)


class BNSID(OTBNInsn):
    insn = insn_for_mnemonic('bn.sid', 5)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.grs2 = op_vals['grs2']
        self.grs2_inc = op_vals['grs2_inc']
        self.offset = op_vals['offset']
        self.grs1 = op_vals['grs1']
        self.grs1_inc = op_vals['grs1_inc']

    def execute(self, state: OTBNState) -> Optional[Iterator[None]]:
        if self.grs1_inc and self.grs2_inc:
            state.stop_at_end_of_cycle(ErrBits.ILLEGAL_INSN)
            return

        grs1_val = state.gprs.get_reg(self.grs1).read_unsigned()
        addr = (grs1_val + self.offset) & ((1 << 32) - 1)
        grs2_val = state.gprs.get_reg(self.grs2).read_unsigned()

        bad_grs1 = state.gprs.call_stack_err and (self.grs1 == 1)
        bad_grs2 = state.gprs.call_stack_err and (self.grs2 == 1)

        saw_err = False

        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            saw_err = True

        if grs2_val > 31 and not bad_grs2:
            state.stop_at_end_of_cycle(ErrBits.ILLEGAL_INSN)
            saw_err = True

        if not state.dmem.is_valid_256b_addr(addr) and not bad_grs1:
            state.stop_at_end_of_cycle(ErrBits.BAD_DATA_ADDR)
            saw_err = True

        if saw_err:
            return

        if self.grs1_inc:
            new_grs1_val = (grs1_val + 32) & ((1 << 32) - 1)
            state.gprs.get_reg(self.grs1).write_unsigned(new_grs1_val)

        if self.grs2_inc:
            new_grs2_val = grs2_val + 1
            state.gprs.get_reg(self.grs2).write_unsigned(new_grs2_val)

        yield

        wrs = grs2_val & 0x1f
        wrs_val = state.wdrs.get_reg(wrs).read_unsigned()

        state.dmem.store_u256(addr, wrs_val)


class BNMOV(OTBNInsn):
    insn = insn_for_mnemonic('bn.mov', 2)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs = op_vals['wrs']

    def execute(self, state: OTBNState) -> None:
        value = state.wdrs.get_reg(self.wrs).read_unsigned()
        state.wdrs.get_reg(self.wrd).write_unsigned(value)


class BNTRANS8(OTBNInsn):
    insn = insn_for_mnemonic('bn.trans8', 2)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wrs = op_vals['wrs']

    def execute(self, state: OTBNState) -> None:
        for i in range(8):
            result = 0
            for j in range(7, -1, -1):
                result = (result << 32) | (extract_sub_word(state.wdrs.get_reg(self.wrs + j).read_unsigned(), 32, i) & ((1 << 32) - 1))
            state.wdrs.get_reg(self.wrd + i).write_unsigned(result)


class BNMOVR(OTBNInsn):
    insn = insn_for_mnemonic('bn.movr', 4)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.grd = op_vals['grd']
        self.grd_inc = op_vals['grd_inc']
        self.grs = op_vals['grs']
        self.grs_inc = op_vals['grs_inc']

    def execute(self, state: OTBNState) -> Optional[Iterator[None]]:
        if self.grs_inc and self.grd_inc:
            state.stop_at_end_of_cycle(ErrBits.ILLEGAL_INSN)
            return

        grd_val = state.gprs.get_reg(self.grd).read_unsigned()
        grs_val = state.gprs.get_reg(self.grs).read_unsigned()

        bad_grs = state.gprs.call_stack_err and (self.grs == 1)
        bad_grd = state.gprs.call_stack_err and (self.grd == 1)

        saw_err = False

        if state.gprs.call_stack_err:
            state.stop_at_end_of_cycle(ErrBits.CALL_STACK)
            saw_err = True

        if grd_val > 31 and not bad_grd:
            state.stop_at_end_of_cycle(ErrBits.ILLEGAL_INSN)
            saw_err = True

        if grs_val > 31 and not bad_grs:
            state.stop_at_end_of_cycle(ErrBits.ILLEGAL_INSN)
            saw_err = True

        if saw_err:
            return

        wrd = grd_val & 0x1f
        wrs = grs_val & 0x1f

        if self.grd_inc:
            new_grd_val = grd_val + 1
            state.gprs.get_reg(self.grd).write_unsigned(new_grd_val)

        if self.grs_inc:
            new_grs_val = grs_val + 1
            state.gprs.get_reg(self.grs).write_unsigned(new_grs_val)

        yield

        value = state.wdrs.get_reg(wrs).read_unsigned()
        state.wdrs.get_reg(wrd).write_unsigned(value)


class BNWSRR(OTBNInsn):
    insn = insn_for_mnemonic('bn.wsrr', 2)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wrd = op_vals['wrd']
        self.wsr = op_vals['wsr']

    def execute(self, state: OTBNState) -> Optional[Iterator[None]]:
        # The first, and possibly only, cycle of execution.
        if not state.wsrs.check_idx(self.wsr):
            # Invalid WSR index. Stop with an illegal instruction error.
            state.stop_at_end_of_cycle(ErrBits.ILLEGAL_INSN)
            return

        if self.wsr == 0x1:
            # A read from RND. If a RND value is not available, request_value()
            # initiates or continues an EDN request and returns False. If a RND
            # value is available, it returns True.
            while not state.wsrs.RND.request_value():
                # There's a pending EDN request. Stall for a cycle.
                yield

        # At this point, the WSR is ready. Does it have a valid value? (It
        # might not if this is a sideload key register and keymgr hasn't
        # provided us with a value). If not, fail with a KEY_INVALID error.
        if not state.wsrs.has_value_at_idx(self.wsr):
            state.stop_at_end_of_cycle(ErrBits.KEY_INVALID)
            return

        # The WSR is ready and has a value. Read it.
        val = state.wsrs.read_at_idx(self.wsr)
        state.wdrs.get_reg(self.wrd).write_unsigned(val)


class BNWSRW(OTBNInsn):
    insn = insn_for_mnemonic('bn.wsrw', 2)

    def __init__(self, raw: int, op_vals: Dict[str, int]):
        super().__init__(raw, op_vals)
        self.wsr = op_vals['wsr']
        self.wrs = op_vals['wrs']

    def execute(self, state: OTBNState) -> None:
        val = state.wdrs.get_reg(self.wrs).read_unsigned()
        state.wsrs.write_at_idx(self.wsr, val)


INSN_CLASSES = [
    ADD, ADDI, LUI, SUB, SLL, SLLI, SRL, SRLI, SRA, SRAI,
    AND, ANDI, OR, ORI, XOR, XORI,
    LW, SW,
    BEQ, BNE, JAL, JALR,
    CSRRS, CSRRW,
    ECALL,
    LOOP, LOOPI,
    SHAKESTART, SHAKEABSORB, SHAKESQUEEZE,

    BNADD, BNADDC, BNADDI, BNADDM,
    BNMULMV,
    BNMULQACC, BNMULQACCWO, BNMULQACCSO,
    BNSUB, BNSUBB, BNSUBI, BNSUBM,
    BNAND, BNOR, BNNOT, BNXOR,
    BNANDV, BNORV,
    BNRSHI,
    BNSEL,
    BNCMP, BNCMPB,
    BNLID, BNSID,
    BNMOV, BNMOVR, BNTRANS8,
    BNWSRR, BNWSRW
]
