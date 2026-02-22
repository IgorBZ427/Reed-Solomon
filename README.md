# Reed-Solomon FEC — RTL Implementation

A synthesizable RTL implementation of a Reed-Solomon Forward Error Correction (FEC) encoder and decoder, targeting FPGA/ASIC, aligned to the **USB4 RS-FEC specification** (Appendix A.5.1).

---

## What Is This?

Reed-Solomon (RS) codes are linear block codes widely used for error correction in communications and storage. This project implements RS(197, 194) over GF(2⁸):

- **n = 197** total symbols, **k = 194** data symbols, **n−k = 4** parity symbols (bytes)
- Each block can correct up to **t = 2 symbol errors**
- Symbols are 8-bit bytes; input arrives **4 symbols (32 bits) per clock cycle**
- Generator polynomial: `g(x) = x⁴ + 15x³ + 54x² + 120x + 64`

---

## Why

The design is motivated by USB4 Gen 2/3 RS-FEC requirements. The goal is a high-frequency, hardware-efficient implementation that can be verified against known USB4 test patterns.

---

## Objectives

- Synthesizable RTL at **> 200 MHz** (FPGA/ASIC), verified with Yosys or equivalent
- Encoder generates **4 parity bytes** per RS frame (194 data symbols)
- Decoder returns validity indication within **3 clock cycles** after a full frame is received
- Decoder corrects up to **2 symbol errors** and outputs error location + magnitude
- `not_valid` flag for frames with more than 2 corrupted symbols (uncorrectable)
- Python model used as POC and golden reference for RTL verification

---

## Requirements

| Parameter | Value |
|-----------|-------|
| Code | RS(197, 194) |
| Field | GF(2⁸), primitive polynomial for GF(256) |
| Symbol width | 8 bits |
| Input width | 32 bits (4 symbols/cycle) |
| Max correctable errors | t = 2 symbols |
| Target frequency | > 200 MHz |
| Decoder algorithm | Reformulated inversionless Berlekamp-Massey (RiBM) |

---

## Architecture

### Encoder
- LFSR-based polynomial division by `g(x)`, operating on 4 symbols per clock
- SOF signal marks the start of each 194-symbol frame
- First clock: 6 symbols (`m_high` + `m_low`); subsequent clocks: 4 symbols (`m_high`)
- Output: 4 parity bytes, valid when next SOF arrives

### Decoder Pipeline (~5 clock latency)
1. **Syndrome calculation** — 4 parallel syndrome cells (S₁–S₄), one per input symbol
2. **Berlekamp-Massey (RiBM)** — computes error locator polynomial σ(x) and error evaluator ω(x)
3. **Chien search** — evaluates σ(x) at all 197 positions in parallel (combinational)
4. **Forney algorithm** — computes error magnitude at each detected location

**Error/invalid detection:** if Chien search finds fewer roots than `deg(σ)`, or `deg(σ) > t`, the frame is flagged as uncorrectable.

---

## Module Interfaces

**Encoder**
```verilog
module RS_encoder #(parameter SYMB_WIDTH = 8) (
    input  clk, rst_n,
    input  sof,                          // start of frame
    input  [SYMB_WIDTH*4-1:0] m_high,    // 4 symbols per clock
    input  [SYMB_WIDTH*2-1:0] m_low,     // 2 extra symbols on SOF
    input  input_valid,
    output [SYMB_WIDTH*4-1:0] parity_out // 4-byte parity, valid on next SOF
);
```

**Decoder**
```verilog
module RS_decoder #(parameter SYMB_WIDTH = 8, parameter T = 2) (
    input  clk, rst_n,
    input  [SYMB_WIDTH*4-1:0] data_in,
    input  input_valid,
    input  dec_align_in,                 // frame toggle
    input  dec_sof_in,                   // start of frame
    output dec_error_valid,              // uncorrectable frame
    output dec_output_valid,             // result ready
    output dec_no_error_found,           // clean frame
    output [SYMB_WIDTH-1:0] err1_mag, err2_mag,  // error magnitudes
    output [SYMB_WIDTH-1:0] err1_loc, err2_loc   // error locations
);
```

---

## Repository Structure

```
encoder/    — RS encoder RTL
decoder/    — RS decoder RTL (syndrome, BM, Chien, Forney)
top/        — top-level integration
rs_gf/      — GF(256) arithmetic (log/exp tables, multipliers)
verif/      — cocotb testbenches (encoder, decoder, top)
models/     — Python golden model (POC + verification)
docs/       — design documentation
```

---

## References

- [Tom Verbeure — Reed-Solomon blog](https://tomverbeure.github.io/2022/08/07/Reed-Solomon.html)
- [tomerfiliba/reedsolomon (LRQ3000)](https://github.com/tomerfiliba-org/reedsolomon/tree/master/src/reedsolo)
- [lrq3000/unireedsolomon](https://github.com/lrq3000/unireedsolomon)
- [Wikiversity — RS Codes for Coders](https://en.wikiversity.org/wiki/Reed%E2%80%93Solomon_codes_for_coders)
- USB4 Spec Appendix A.5.1 — Gen 2 and Gen 3 RS-FEC Examples
- Sarwate & Shanbhag, *High-Speed Architectures for Reed–Solomon Decoders*, IEEE TVLSI, Vol. 9, 2002
- Blahut, *Theory and Practice of Error Control Codes*, Addison-Wesley, 1983
