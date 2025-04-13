# -*- coding: utf-8 -*-
# https://www.mql5.com/en/forum/149178

import time
import struct

def main():

    header    = "L64s12sLLLL52s"
    rates     = "<Qddddqiq"
    version   = 401
    copyright = b"(C)opyright 2003, MetaQuotes Software Corp."
    symbol    = b"BLANK"
    timeframe = 1
    digits    = 2
    unixtime  = int(time.time())
    unused    = b""

    filename  = symbol.decode() + str(timeframe) + '.hst'
    print(filename)

    with open(filename, 'wb') as f:

        f.write(struct.pack(header, version, copyright, symbol, timeframe, digits, unixtime, unixtime, unused))

        # total 60 bytes : time, open, high low, close, volume, spread, real_volume
        f.write(struct.pack(rates, unixtime, 100, 120, 90, 110, 100, 1, 1))

if __name__== "__main__":
    main()
