import random

random.seed(42)  # for reproducibility, document this in your report
seeds = []
while len(seeds) < 128:
    s = random.randint(1, 2**32 - 1)  # avoid 0
    if s not in seeds:                 # keep them distinct (not strictly required, but good practice)
        seeds.append(s)

# Write out as a .mem / .hex file for Verilog $readmemh
with open('seeds.hex', 'w') as f:
    for s in seeds:
        f.write(f'{s:08x}\n')
