import time
import os

while True:
    idx = int(str(time.monotonic())[-5:])
    print(os.system('psql -c "SELECT * FROM frn.dimcand WHERE cand_sk = %d" cfdm' % idx))
    time.sleep(10)