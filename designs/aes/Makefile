# aes: see mk/design.mk for the list of targets (make sim, synth, pnr, ...)
#
# The chip is aes_ctr, a private-link encryptor; aes128 is the AES core inside
# it and aes_sbox the S-box. Regenerate the S-box table with
#   python3 ../../python/aes_model.py --sbox
TOP := aes_ctr
RTL := rtl/aes_sbox.v rtl/aes128.v rtl/aes_ctr.v
TB  := tb/aes_ctr_tb.v
include ../../mk/design.mk
