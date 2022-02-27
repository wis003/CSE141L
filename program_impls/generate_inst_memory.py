#!/usr/bin/env python3

# Totally optional, here's a neat thing:
# You can create a reverse-mapping, such that waveform tools will show the
# original instruction.
# The waveform viewing tool needs a mapping of # `$value $display_string`.
# Only want to write each unique machine code once though.
# mcodes = set()

# Here's a lookup table for opcodes
ops = {
		#(00)
		'get': (0, '00000'),
		'put': (0, '00001'),
		'lw' : (0, '00010'),
		'sw' : (0, '00011'),
		'seq': (0, '00100'),
		'slt': (0, '00101'),

		#(01)
		'set': (1, 0, '010'),
		'not': (1, 1, '011'),

		#(10)
		'add'   : (2, '10000'),
		'addi'  : (2, '10001'),
		'sub'   : (2, '10010'),
		'and'   : (2, '10011'),
		'or'    : (2, '10100'),
		'xor'   : (2, '10101'),
		'sleft' : (2, '10110'),
		'sright': (2, '10111'),

		#(11)
		'beq': (3, '110'),
		'bne': (3, '111'),
		}

# This is a neat trick to catch programming errors
# TOTAL_IMEM_SIZE = 2**10

# Don't need to do anything fancy here
with open('program1.S') as ifile, open('inst_mem.txt', 'w') as imem:
	for lineno, line in enumerate(ifile):
		try:
			# Skip over blank lines, remove comments
			line = line.strip()
			line = line.split('//')[0].strip()
			if line == '':
				continue
			
			machine_code = ''
			# Special-case:
			if line[:4] == 'halt':
				machine_code = '111111111'
			else:
				curr = line.split()
				mapping = ops[curr[0]]

				if mapping[0] == 0:
					machine_code = mapping[1] + '{:02b}'.format(int(curr[1].split('r')[1])) + '{:02b}'.format(int(curr[2].split('r')[1]))

				if mapping[0] == 1:
					if mapping[1] == 0:
						machine_code = mapping[2] + '{:06b}'.format(int(curr[1]))
					if mapping[1] == 1:
						machine_code = mapping[2] + '{:02b}'.format(int(curr[1].split('r')[1])) + '1111'

				if mapping[0] == 2:
					machine_code = mapping[1] + '{:02b}'.format(int(curr[1].split('r')[1])) + '{:02b}'.format(int(curr[2].split('r')[1]))

				if mapping[0] == 3:
					machine_code = mapping[1] + '{:02b}'.format(int(curr[1].split('r')[1])) + '{:02b}'.format(int(curr[2].split('r')[1])) + '{:02b}'.format(int(curr[3].split('r')[1]))

			# Write the imem entry
			imem.write(machine_code + '\n')
			# TOTAL_IMEM_SIZE -= 1

			# Write out our waveform decoder
			# if machine_code not in mcodes:
			# 	line = line.replace('\t', ' ')
			# 	mcodes.add(machine_code)
		except:
			print("Error Parsing Line ", lineno)
			print(">>>{}<<<".format(line))
			print()
			raise

	# This is a neat trick to catch programming errors:
	# Fill the rest of instruction memory with illegal instructions.
	# while TOTAL_IMEM_SIZE:
	# 	imem.write('xxxxxxxxx\n')
	# 	TOTAL_IMEM_SIZE -= 1