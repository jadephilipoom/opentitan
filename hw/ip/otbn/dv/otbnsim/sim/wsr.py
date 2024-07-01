# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

from typing import List, Optional, Sequence, Tuple
from Crypto.Hash import SHAKE128, SHAKE256

from .trace import Trace

from .ext_regs import OTBNExtRegs


class TraceWSR(Trace):
    def __init__(self, wsr_name: str, new_value: Optional[int]):
        self.wsr_name = wsr_name
        self.new_value = new_value

    def trace(self) -> str:
        s = '{} = '.format(self.wsr_name)
        if self.new_value is None:
            s += '0x' + 'x' * 8
        else:
            s += '{:#x}'.format(self.new_value)
        return s

    def rtl_trace(self) -> str:
        return '> {}: {}'.format(self.wsr_name,
                                 Trace.hex_value(self.new_value, 256))


class WSR:
    '''Models a Wide Status Register'''
    def __init__(self, name: str):
        self.name = name
        self._pending_write = False

    def has_value(self) -> bool:
        '''Return whether the WSR has a valid value'''
        return True

    def on_start(self) -> None:
        '''Reset the WSR if necessary for the start of an operation'''
        return

    def read_unsigned(self) -> int:
        '''Get the stored value as a 256-bit unsigned value'''
        raise NotImplementedError()

    def write_unsigned(self, value: int) -> None:
        '''Set the stored value as a 256-bit unsigned value'''
        raise NotImplementedError()

    def read_signed(self) -> int:
        '''Get the stored value as a 256-bit signed value'''
        uval = self.read_unsigned()
        return uval - (1 << 256 if uval >> 255 else 0)

    def write_signed(self, value: int) -> None:
        '''Set the stored value as a 256-bit signed value'''
        assert -(1 << 255) <= value < (1 << 255)
        uval = (1 << 256) + value if value < 0 else value
        self.write_unsigned(uval)

    def commit(self) -> None:
        '''Commit pending changes'''
        self._pending_write = False
        return

    def abort(self) -> None:
        '''Abort pending changes'''
        self._pending_write = False
        return

    def changes(self) -> Sequence[Trace]:
        '''Return list of pending architectural changes'''
        return []


class DumbWSR(WSR):
    '''Models a WSR without special behaviour'''
    def __init__(self, name: str):
        super().__init__(name)
        self._value = 0
        self._next_value = None  # type: Optional[int]

    def on_start(self) -> None:
        self._value = 0
        self._next_value = None

    def read_unsigned(self) -> int:
        return self._value

    def write_unsigned(self, value: int) -> None:
        assert 0 <= value < (1 << 256)
        self._next_value = value
        self._pending_write = True

    def write_invalid(self) -> None:
        self._next_value = None
        self._pending_write = True

    def commit(self) -> None:
        if self._next_value is not None:
            self._value = self._next_value
        self._next_value = None
        self._pending_write = False

    def abort(self) -> None:
        self._next_value = None
        self._pending_write = False

    def changes(self) -> List[TraceWSR]:
        return ([TraceWSR(self.name, self._next_value)]
                if self._pending_write else [])


class RandWSR(WSR):
    '''The magic RND WSR

    RND is special as OTBN can stall on reads to it. A read from RND either
    immediately returns data from a cache of a previous EDN request (triggered
    by writing to the RND_PREFETCH CSR) or waits for data from the EDN. To
    model this, anything reading from RND must first call `request_value` which
    returns True if the value is available.

    '''
    def __init__(self, name: str, ext_regs: OTBNExtRegs):
        super().__init__(name)

        self._random_value = None  # type: Optional[int]
        self._next_random_value = None  # type: Optional[int]
        self._ext_regs = ext_regs

        # The pending_request flag says that we've started an instruction that
        # reads from RND. Using it means that we can avoid repeated requests
        # from the EdnClient which is important because it avoids a request on
        # the single cycle where the EdnClient has passed data back to us but
        # that data hasn't yet been committed. If we sent another request on
        # that cycle, the EdnClient would start another transaction.
        self._pending_request = False
        self._next_pending_request = False

        self._fips_err = False
        self.fips_err_escalate = False

        self._rep_err = False
        self.rep_err_escalate = False

    def read_unsigned(self) -> int:
        assert self._random_value is not None
        self._next_random_value = None
        self.rep_err_escalate = self._rep_err
        self.fips_err_escalate = self._fips_err
        return self._random_value

    def read_u32(self) -> int:
        '''Read a 32-bit unsigned result'''
        self.rep_err_escalate = self._rep_err
        self.fips_err_escalate = self._fips_err
        return self.read_unsigned() & ((1 << 32) - 1)

    def write_unsigned(self, value: int) -> None:
        '''Writes to RND are ignored

        Note this is different to `set_unsigned`. This is used by executing
        instruction, see `set_unsigned` docstring for more details
        '''
        return

    def on_start(self) -> None:
        self._next_random_value = None
        self._next_pending_request = False
        self.fips_err_escalate = False
        self.rep_err_escalate = False

    def commit(self) -> None:
        self._random_value = self._next_random_value
        self._pending_request = self._next_pending_request

    def request_value(self) -> bool:
        '''Signals intent to read RND, returns True if a value is available'''
        if self._random_value is not None:
            return True
        if not self._pending_request:
            self._next_pending_request = True
            self._ext_regs.rnd_request()
        return False

    def set_unsigned(self, value: int, fips_err: bool, rep_err: bool) -> None:
        '''Sets a random value that can be read by a future `read_unsigned`

        This is different to `write_unsigned`, that is used by an executing
        instruction to write to RND. This is used by the simulation environment
        to provide a value that is later read by `read_unsigned` and doesn't
        relate to instruction execution (e.g. in an RTL simulation it monitors
        the EDN bus and supplies the simulator with an RND value when a fresh
        one is seen on the EDN bus).
        '''
        assert 0 <= value < (1 << 256)
        self._fips_err = fips_err
        self._rep_err = rep_err
        self.fips_err_escalate = False
        self.rep_err_escalate = False
        self._next_random_value = value
        self._next_pending_request = False


class URNDWSR(WSR):
    '''Models URND PRNG Structure'''
    def __init__(self, name: str):
        super().__init__(name)
        seed = [0x84ddfadaf7e1134d, 0x70aa1c59de6197ff,
                0x25a4fe335d095f1e, 0x2cba89acbe4a07e9]
        self.state = [seed, 4 * [0], 4 * [0], 4 * [0], 4 * [0]]
        self.out = 4 * [0]
        self._next_value = None  # type: Optional[int]
        self._value = None  # type: Optional[int]
        self.running = False

    def rol(self, n: int, d: int) -> int:
        '''Rotate n left by d bits'''
        return ((n << d) & ((1 << 64) - 1)) | (n >> (64 - d))

    def read_u32(self) -> int:
        '''Read a 32-bit unsigned result'''
        return self.read_unsigned() & ((1 << 32) - 1)

    def write_unsigned(self, value: int) -> None:
        '''Writes to URND are ignored'''
        return

    def on_start(self) -> None:
        self.running = False

    def read_unsigned(self) -> int:
        assert self._value is not None
        return self._value

    def state_update(self, data_in: List[int]) -> List[int]:
        a_in = data_in[3]
        b_in = data_in[2]
        c_in = data_in[1]
        d_in = data_in[0]

        a_out = a_in ^ b_in ^ d_in
        b_out = a_in ^ b_in ^ c_in
        c_out = a_in ^ ((b_in << 17) & ((1 << 64) - 1)) ^ c_in
        d_out = self.rol(d_in, 45) ^ self.rol(b_in, 45)
        assert a_out < (1 << 64)
        assert b_out < (1 << 64)
        assert c_out < (1 << 64)
        assert d_out < (1 << 64)
        return [d_out, c_out, b_out, a_out]

    def set_seed(self, value: List[int]) -> None:
        assert(len(value) == 4)
        self.running = True
        self.state[0] = value
        # Step immediately to update the internal state with the new seed
        self.step()

    def step(self) -> None:
        if self.running:
            mask64 = (1 << 64) - 1
            mid = 4 * [0]
            nv = 0
            for i in range(4):
                st_i = self.state[i]
                self.state[i + 1] = self.state_update(st_i)
                mid[i] = (st_i[3] + st_i[0]) & mask64
                self.out[i] = (self.rol(mid[i], 23) + st_i[3]) & mask64
                nv |= self.out[i] << (64 * i)
            self._next_value = nv
            self.state[0] = self.state[4]

    def commit(self) -> None:
        if self._next_value is not None:
            self._value = self._next_value

    def abort(self) -> None:
        self._next_value = 0

    def changes(self) -> List[TraceWSR]:
        return ([])


class KeyTrace(Trace):
    def __init__(self, name: str, new_value: Optional[int]):
        self.name = name
        self.new_value = new_value

    def trace(self) -> str:
        val_desc = '(unset)' if self.new_value is None else self.new_value
        return '{} = {}'.format(self.name, val_desc)


class SideloadKey:
    '''Represents a sideloaded key, with 384 bits of data and a valid signal'''
    def __init__(self, name: str):
        self.name = name
        self._value = None  # type: Optional[int]
        self._new_value = None  # type: Optional[Tuple[bool, int]]

    def has_value(self) -> bool:
        return self._value is not None

    def read_unsigned(self, shift: int) -> int:
        # The simulator should be careful not to call read_unsigned() unless it
        # has first checked that the value exists.
        assert self._value is not None

        mask256 = (1 << 256) - 1
        return (self._value >> shift) & mask256

    def set_unsigned(self, value: Optional[int]) -> None:
        '''Unlike the WSR write_unsigned, this takes effect immediately

        That way, we can correctly model the combinatorial path from sideload
        keys to the WSR file in the RTL. Note that we do still report the
        change until the next commit.
        '''
        assert value is None or (0 <= value < (1 << 384))
        self._value = value
        self._new_value = (False, 0) if value is None else (True, value)

    def changes(self) -> List[KeyTrace]:
        if self._new_value is not None:
            vld, value = self._new_value
            return [KeyTrace(self.name, value if vld else None)]
        else:
            return []

    def commit(self) -> None:
        self._new_value = None


class KeyWSR(WSR):
    def __init__(self, name: str, shift: int, key_reg: SideloadKey):
        assert 0 <= shift < 384
        super().__init__(name)
        self._shift = shift
        self._key_reg = key_reg

    def has_value(self) -> bool:
        return self._key_reg.has_value()

    def read_unsigned(self) -> int:
        return self._key_reg.read_unsigned(self._shift)

    def write_unsigned(self, value: int) -> None:
        return

class KmacBlock:
    '''Emulates the KMAC hardware block.'''
    _CMD_START = 0x1d
    _CMD_PROCESS = 0x2e
    _CMD_RUN = 0x31
    _CMD_DONE = 0x16
    _STATUS_IDLE = 'IDLE'
    _STATUS_ABSORB = 'ABSORB'
    _STATUS_SQUEEZE = 'SQUEEZE'
    _STRENGTH_128 = 0x0
    _STRENGTH_256 = 0x2

    # Message FIFO size in bytes. See:
    # https://github.com/lowRISC/opentitan/blob/1b56f197b49d5f597867561d0a153d2e7a985909/hw/ip/kmac/rtl/kmac_pkg.sv#L37
    # https://github.com/lowRISC/opentitan/blob/1b56f197b49d5f597867561d0a153d2e7a985909/hw/ip/kmac/rtl/sha3_pkg.sv#L52
    _MSG_FIFO_SIZE_BYTES = 10 * 8

    # Rate at which the Keccak core absorbs data from the message FIFO
    # (bytes/cycle). See:
    # https://github.com/lowRISC/opentitan/blob/1b56f197b49d5f597867561d0a153d2e7a985909/hw/ip/kmac/rtl/keccak_round.sv#L50
    _MSG_FIFO_ABSORB_BYTES_PER_CYCLE = 8

    # Cycles for a Keccak round. See:
    # https://opentitan.org/book/hw/ip/kmac/doc/theory_of_operation.html#keccak-round
    _KECCAK_CYCLES_PER_ROUND = 4
    _KECCAK_NUM_ROUNDS = 24

    # Number of bytes that can be sent to KMAC per cycle over the application
    # interface.
    _APP_INTF_BYTES_PER_CYCLE = 8

    # FIFO within OTBN that waits to send message data over the application
    # interface. Without this we'd have to stall on every message WSR write
    # while we wait to send data to KMAC.
    _APP_INTF_FIFO_SIZE_BYTES = 64

    def __init__(self):
        self._reset()

    def _reset(self) -> None:
        self._status = self._STATUS_IDLE
        self._core_cycles_remaining = None
        self._state = None
        self._rate_bytes = None
        self._read_offset = 0
        self._msg_fifo = bytes()
        self._app_intf_fifo = bytes()
        self._core_pending_bytes = 0
        self._msg_len = 0
        self._pending_process = False

    def issue_cmd(self, value: int) -> None:
        '''Issue a command to the KMAC block.

        The lowest 6 bits are the command code to issue. For `start`, the next
        two bits indicate the strength. All other bits are ignored.
        '''
        cmd = value & 0x1f
        if cmd == self._CMD_START:
            strength = (value >> 5) & 3
            self.start(strength)
        elif cmd == self._CMD_DONE:
            self.done()
        else:
            raise ValueError(f'KMAC: Invalid command: {hex(cmd)}')

    def message_done(self) -> None:
        '''Indicate that the message input is done.'''
        # Don't issue the `process` command yet; wait for FIFOs to clear.
        self._pending_process = True

    def is_idle(self) -> bool:
        return self._status == self._STATUS_IDLE

    def is_absorbing(self) -> bool:
        return self._status == self._STATUS_ABSORB

    def is_squeezing(self) -> bool:
        return self._status == self._STATUS_SQUEEZE

    def digest_ready(self) -> bool:
        return self.is_squeezing() and (self._core_cycles_remaining == 0)

    def start(self, strength: int) -> None:
        '''Starts a SHAKE hashing operation.'''
        if not self.is_idle():
            raise ValueError('KMAC: Cannot issue `start` command in '
                             f'{self._status} status.')
        self._status = self._STATUS_ABSORB
        if strength == self._STRENGTH_128:
            self._state = SHAKE128.new()
            self._rate_bytes = (1600 - (128*2)) // 8
        elif strength == self._STRENGTH_256:
            self._state = SHAKE256.new()
            self._rate_bytes = (1600 - (256*2)) // 8
        else:
            raise ValueError(f'Invalid strength: {strength}.')

        # Important assumption: since we send data to the core in fixed-size
        # chunks, we need to make sure the chunk size divides the rate.
        assert self._rate_bytes % self._MSG_FIFO_ABSORB_BYTES_PER_CYCLE == 0

    def msg_fifo_bytes_available(self) -> int:
        return self._MSG_FIFO_SIZE_BYTES - len(self._msg_fifo)

    def app_intf_fifo_bytes_available(self) -> int:
        return self._APP_INTF_FIFO_SIZE_BYTES - len(self._app_intf_fifo)

    def write(self, msg: bytes) -> None:
        '''Appends new message data to an ongoing hashing operation.

        Check `app_intf_fifo_bytes_available` to ensure there is enough space
        in the FIFO before attempting to write.
        '''
        if not self.is_absorbing():
            raise ValueError(f'KMAC: Cannot write in {self._status} status.')
        if len(msg) > self.app_intf_fifo_bytes_available():
            raise ValueError('KMAC: Not enough space available in message FIFO.')
        # import sys
        # print(f"absorb Kmac: {msg.hex()}", file=sys.stderr)
        self._app_intf_fifo += msg
        self._msg_len += len(msg)

    def _start_keccak_core(self) -> None:
        self._core_cycles_remaining = self._KECCAK_NUM_ROUNDS * self._KECCAK_CYCLES_PER_ROUND

    def _core_is_busy(self) -> None:
        return self._core_cycles_remaining is not None and self._core_cycles_remaining > 0

    def _process(self) -> None:
        '''Issues a `process` command to the KMAC block.

        Signals to the hardware that the message is done and it should compute
        a digest. The amount of digest computed depends on the rate of the
        Keccak function instantiated (1600 - capacity, e.g. 1344 bits for
        SHAKE128).
        '''
        if not self.is_absorbing():
            raise ValueError('KMAC: Cannot issue `process` command in '
                             f'{self._status} status.')
        self._status = self._STATUS_SQUEEZE

    def run(self) -> None:
        '''Issues a `run` command to the KMAC block.

        This command should be issued if additional digest data, beyond the
        Keccak rate, is needed. It runs the Keccak core again to generate new
        digest material. The state buffer is invalid until the core computation
        is complete; the caller needs to read the previous digest before
        calling run().
        '''
        if not self.is_squeezing():
            raise ValueError('KMAC: Cannot issue `run` command in '
                             f'{self._status} status.')
        self._start_keccak_core()
        self._read_offset = 0

    def done(self) -> None:
        '''Finishes a hashing operation.'''
        if not self.is_squeezing():
            raise ValueError('KMAC: Cannot issue `done` command in '
                             f'{self._status} status.')
        self._reset()

    def step(self) -> None:
        if self.is_idle():
            return

        core_available = self._rate_bytes - self._core_pending_bytes
        absorb_rate = self._MSG_FIFO_ABSORB_BYTES_PER_CYCLE
        if core_available >= absorb_rate:
            if len(self._msg_fifo) >= absorb_rate:
                # Absorb a new chunk of the message.
                self._core_pending_bytes += absorb_rate
                self._state.update(self._msg_fifo[:absorb_rate])
                self._msg_fifo = self._msg_fifo[absorb_rate:]
            elif self._pending_process and not self._app_intf_fifo:
                # Push the remainder of the message (if present) plus some
                # padding. We model the timing of pushing the padding but not
                # the padding itself, since the SHA3 library does that for us.
                self._core_pending_bytes += absorb_rate
                if len(self._msg_fifo) > 0:
                  self._state.update(self._msg_fifo)
                  self._msg_fifo = bytes()
        if self.msg_fifo_bytes_available() >= self._APP_INTF_BYTES_PER_CYCLE:
            # Pass data from the application interface FIFO to the message FIFO.
            nbytes = min(len(self._app_intf_fifo), self._APP_INTF_BYTES_PER_CYCLE)
            self._msg_fifo += self._app_intf_fifo[:nbytes]
            self._app_intf_fifo = self._app_intf_fifo[nbytes:]

        # Either step the core or check if we can start it.
        if self._core_is_busy():
            self._core_cycles_remaining -= 1
        elif self._core_pending_bytes == self._rate_bytes:
            self._start_keccak_core()
            self._core_pending_bytes = 0
            if self._pending_process and not self._app_intf_fifo and not self._msg_fifo:
                # Just finished padding; send the process command.
                self._process()
                self._pending_process = False


    def max_read_bytes(self) -> int:
        '''Returns the maximum readable bytes before a `run` command.'''
        return self._rate_bytes - self._read_offset

    def read(self, num_bytes: int) -> bytes:
        if not self.digest_ready():
            raise ValueError(f'KMAC: Digest is not ready for read.')
        if num_bytes > self.max_read_bytes():
            raise ValueError(f'KMAC: Read request exceeds Keccak rate.')
        self._read_offset += num_bytes
        ret = self._state.read(num_bytes)
        # import sys
        # print(f"read Kmac: {ret.hex()}", file=sys.stderr)
        return ret

class KeccakMsgWSR(WSR):
    '''Keccak message WSR: sends data to the KMAC hardware block.

    Reads from this register always return 0.

    When KMAC is in the "absorb" state, writes to this register will trigger
    writes to KMAC's message FIFO. Otherwise, writes will be ignored.

    KMAC can only receive about 64 bits of data per cycle via the hardware
    application interface. If there is not enough space in the internal FIFO to
    hold the data from a new write, the instruction stalls while it waits for
    space to become available.
    '''
    def __init__(self, name: str, kmac: KmacBlock):
        super().__init__(name)
        self._kmac = kmac
        self._next_write_len = 32

    def set_next_write_len(self, value: int):
        '''Sets the byte-length of the next write.

        After one more write, the length will be reset to a full 32 bytes.
        '''
        assert 0 <= value <= 32
        self._next_write_len = value

    def read_unsigned(self) -> int:
        return 0

    def write_unsigned(self, value: int) -> None:
        assert self.is_ready()
        assert 0 <= value < (1 << 256)
        if self._kmac.is_absorbing():
            self._next_value = value
            self._pending_write = True

    def is_ready(self) -> bool:
        '''Indicates if there is enough space in the FIFO to receive a write.'''
        return self._kmac.app_intf_fifo_bytes_available() >= self._next_write_len

    def commit(self) -> None:
        if self._pending_write:
            value_bytes = int.to_bytes(self._next_value, byteorder='little', length=32)
            self._kmac.write(value_bytes[:self._next_write_len])
            self._next_write_len = 32
        super().commit()

    def changes(self) -> Sequence[Trace]:
        '''Return list of pending architectural changes'''
        return ([TraceWSR(self.name, self._next_value)]
                if self._pending_write else [])

class KeccakDigestWSR(WSR):
    '''Keccak digest WSR: recieves data from the KMAC hardware block.

    This register is not writeable; writes are always discarded.

    If KMAC is in the "idle" state, reads always return 0. When KMAC is in the
    "absorb" state, reading from this register will issue a `process` command;
    KMAC will move into the "squeeze" state and begin computing the digest.
    OTBN will stall until the digest computation finishes, and KMAC sends the
    first 256 bits of the digest as the read result.

    Reads from this register in the "squeeze" state will pull 256-bit slices of
    the digest sequentially from KMAC. The amount of digest available after
    `process` depends on the rate of the specific Keccak instantiation. If 256
    bits of digest are not available, a read from this register will issue the
    `run` command to KMAC and again OTBN will stall until the full 256 bits is
    ready.
    '''
    def __init__(self, name: str, kmac: KmacBlock):
        super().__init__(name)
        self._kmac = kmac
        self._digest_bytes = bytes()
        self._waiting_for_digest = False
        self._next_pending_request = False

    def has_value(self) -> bool:
        return self._kmac.is_squeezing() and len(self._digest_bytes) == 32

    def request_value(self) -> bool:
        '''Returns true if the full register value is ready.'''
        if self._waiting_for_digest:
            return False
        if self._kmac.is_squeezing() and len(self._digest_bytes) == 32:
            return True
        self._next_pending_request = True
        return False

    def read_unsigned(self) -> int:
        if not self._kmac.is_squeezing():
            return 0
        assert len(self._digest_bytes) == 32
        value = int.from_bytes(self._digest_bytes, byteorder='little')
        self._digest_bytes = bytes()
        return value

    def write_unsigned(self, value: int) -> None:
        return

    def abort(self) -> None:
        self._next_pending_request = False

    def commit(self) -> None:
        if self._waiting_for_digest:
            # Check if new data is ready. We are guaranteed to have enough
            # bytes available because the rate is always higher than 32 bytes.
            if self._kmac.digest_ready():
                self._digest_bytes += self._kmac.read(32 - len(self._digest_bytes))
                self._waiting_for_digest = False
        elif self._next_pending_request:
            if self._kmac.is_absorbing():
                self._digest_bytes = bytes()
                self._kmac.message_done()
                self._waiting_for_digest = True
            elif self._kmac.is_squeezing():
                if self._kmac.max_read_bytes() >= 32:
                    self._digest_bytes = self._kmac.read(32)
                else:
                    self._digest_bytes = self._kmac.read(self._kmac.max_read_bytes())
                    self._kmac.run()
                    self._waiting_for_digest = True

        self._kmac.step()
        self._next_pending_request = False


class WSRFile:
    '''A model of the WSR file'''
    def __init__(self, ext_regs: OTBNExtRegs) -> None:
        self.KeyS0 = SideloadKey('KeyS0')
        self.KeyS1 = SideloadKey('KeyS1')
        self.Kmac = KmacBlock()

        self.MOD = DumbWSR('MOD')
        self.RND = RandWSR('RND', ext_regs)
        self.URND = URNDWSR('URND')
        self.ACC = DumbWSR('ACC')
        self.KeyS0L = KeyWSR('KeyS0L', 0, self.KeyS0)
        self.KeyS0H = KeyWSR('KeyS0H', 256, self.KeyS0)
        self.KeyS1L = KeyWSR('KeyS1L', 0, self.KeyS1)
        self.KeyS1H = KeyWSR('KeyS1H', 256, self.KeyS1)
        self.KeccakMsg = KeccakMsgWSR('KeccakMsg', self.Kmac)

        # TODO: when masking is on, KMAC actually produces the digest in two
        # shares. We should someday emulate this behavior.
        self.KeccakDigest = KeccakDigestWSR('KeccakDigest', self.Kmac)

        self._by_idx = {
            0: self.MOD,
            1: self.RND,
            2: self.URND,
            3: self.ACC,
            4: self.KeyS0L,
            5: self.KeyS0H,
            6: self.KeyS1L,
            7: self.KeyS1H,
            8: self.KeccakMsg,
            9: self.KeccakDigest,
            }


    def on_start(self) -> None:
        '''Called at the start of an operation

        This clears values that don't persist between runs (everything except
        RND and the key registers)
        '''
        for reg in self._by_idx.values():
            reg.on_start()

    def check_idx(self, idx: int) -> bool:
        '''Return True if idx is a valid WSR index'''
        return idx in self._by_idx

    def has_value_at_idx(self, idx: int) -> int:
        '''Return True if the WSR at idx has a valid valu.

        Assumes that idx is a valid index (call check_idx to ensure this).

        '''
        return self._by_idx[idx].has_value()

    def read_at_idx(self, idx: int) -> int:
        '''Read the WSR at idx as an unsigned 256-bit value

        Assumes that idx is a valid index (call check_idx to ensure this).

        '''
        return self._by_idx[idx].read_unsigned()

    def write_at_idx(self, idx: int, value: int) -> None:
        '''Write the WSR at idx as an unsigned 256-bit value

        Assumes that idx is a valid index (call check_idx to ensure this).

        '''
        return self._by_idx[idx].write_unsigned(value)

    def commit(self) -> None:
        self.MOD.commit()
        self.RND.commit()
        self.URND.commit()
        self.ACC.commit()
        self.KeyS0.commit()
        self.KeyS1.commit()
        self.KeccakMsg.commit()
        self.KeccakDigest.commit()

    def abort(self) -> None:
        self.MOD.abort()
        self.RND.abort()
        self.URND.abort()
        self.ACC.abort()
        # We commit changes to the sideloaded keys from outside, even if the
        # instruction itself gets aborted.
        self.KeyS0.commit()
        self.KeyS1.commit()
        self.KeccakMsg.abort()
        self.KeccakDigest.abort()

    def changes(self) -> List[Trace]:
        ret = []  # type: List[Trace]
        ret += self.MOD.changes()
        ret += self.RND.changes()
        ret += self.URND.changes()
        ret += self.ACC.changes()
        ret += self.KeyS0.changes()
        ret += self.KeyS1.changes()
        ret += self.KeccakMsg.changes()
        ret += self.KeccakDigest.changes()
        return ret

    def set_sideload_keys(self,
                          key0: Optional[int],
                          key1: Optional[int]) -> None:
        self.KeyS0.set_unsigned(key0)
        self.KeyS1.set_unsigned(key1)

    def wipe(self) -> None:
        self.MOD.write_invalid()
        self.ACC.write_invalid()
