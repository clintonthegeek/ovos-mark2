#!/usr/bin/env python3
"""Initialise the TAS5806 amp on i2c-1 @ 0x2F without depending on i2cdump."""
import time
from smbus2 import SMBus

DEV = 0x2F

def w(bus, reg, val):
    bus.write_byte_data(DEV, reg, val)
    time.sleep(0.1)

def main():
    with SMBus(1) as b:
        w(b, 0x01, 0x11)   # reset chip
        w(b, 0x78, 0x80)   # clear faults
        w(b, 0x01, 0x00)   # un-reset
        w(b, 0x78, 0x00)   # un-clear-fault
        w(b, 0x33, 0x03)   # 32-bit I2S
        w(b, 0x4C, 0x60)   # vol soft-start
        w(b, 0x30, 0x01)   # SDOUT = DSP input (pre-processing)
        w(b, 0x03, 0x00)   # deep sleep
        w(b, 0x03, 0x02)   # HiZ
        w(b, 0x5C, 0x01)   # first BQ coefficient marker
        w(b, 0x03, 0x03)   # play
        w(b, 0x4C, 0x64)   # final master volume
    print("TAS5806 initialised (vol 0x64)")

if __name__ == "__main__":
    main()
