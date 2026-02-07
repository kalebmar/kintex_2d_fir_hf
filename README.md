# Real-Time 2D FIR Filter on FPGA (Kintex-7)

This project implements a real-time 2D FIR (Finite Impulse Response) filter on a Logsys Kintex-7 FPGA board. The system processes a live video stream from a HDMI source, applies a configurable filter, and outputs the processed grayscale video via HDMI.

The project integrates a hardware-accelerated image processing pipeline with a MicroBlaze-based processor subsystem for configuration via UART.

---

## Key Features

### Hardware Filter

- Real-time video processing  
- Supports resolutions up to 1600×900 @ 60 Hz  
- RGB to Grayscale (Y) conversion pipeline  
- 5×5 pixel filter window  
- 16-bit signed fixed-point coefficients (8-bit fractional part)  
- Saturation logic to handle output overflow  

---

### Processor Subsystem

- MicroBlaze soft-core processor  
- Processor communicates with the FIR filter through an AXI4-Lite interface to update coefficients  
- AXI UART Lite interface for PC communication  
- Custom register interface for runtime coefficient updates  

---

### Hardware

- Logsys Kintex-7 FPGA board  

---

### Tools

- Xilinx Vivado & Vitis (2024.2)  

---

### Language

- Verilog HDL for hardware  
- C for MicroBlaze firmware  
