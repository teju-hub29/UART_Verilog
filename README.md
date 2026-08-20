# UART — Verilog Implementation

A complete UART (Universal Asynchronous Receiver-Transmitter) communication system implemented in Verilog, with separate transmitter and receiver modules and a loopback testbench for end-to-end verification.

## Overview

This project implements asynchronous serial communication from scratch in Verilog RTL, covering:
- A UART Transmitter (`uart_tx.v`) that serializes parallel data with start, stop, and optional parity bits
- A UART Receiver (`uart_rx.v`) that samples incoming serial data and reconstructs the original byte
- Independent testbenches for TX and RX to verify each module in isolation
- A loopback testbench (`uart_loopback_tb.v`) connecting TX directly to RX to verify full round-trip data integrity

## Why this project

UART was my entry point into serial communication protocols — understanding baud rate generation, oversampling for bit synchronization without a shared clock, and frame structure (start bit, data bits, stop bit) before moving on to synchronous protocols like SPI.

## Architecture

```
Parallel Data ──► [UART_TX] ──► Serial Line (TX) ──► [UART_RX] ──► Parallel Data
                                  (start | data bits | stop)
```

- **uart_tx.v** — generates the baud-rate clock, shifts out start bit, data bits, and stop bit
- **uart_rx.v** — detects the start bit, samples each data bit at the correct baud interval, and reassembles the byte
- **uart_tx_tb.v** — verifies transmitter output against expected serial waveform
- **uart_rx_tb.v** — feeds a known serial pattern into the receiver and checks the decoded byte
- **uart_loopback_tb.v** — connects TX output directly to RX input to confirm full transmit-receive integrity

## Verification

Testbenches confirm:
- Correct framing (start bit, 8 data bits, stop bit) on transmit
- Correct sampling and reconstruction of data bits on receive
- Successful loopback: data sent by TX is accurately recovered by RX with no bit errors

## Tools used

- Xilinx Vivado (behavioral simulation, xsim)
- Verilog HDL

## What I'd add next

- Configurable baud rate via parameter
- Parity bit support (even/odd) and error flagging
- FIFO buffering for continuous multi-byte transmission

## Files

```
uart_tx.v           — UART transmitter module
uart_rx.v           — UART receiver module
uart_tx_tb.v        — Transmitter testbench
uart_rx_tb.v        — Receiver testbench
uart_loopback_tb.v  — Full TX→RX loopback testbench
```
