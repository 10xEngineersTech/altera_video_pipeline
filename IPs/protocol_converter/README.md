# Protocol Converter Validation

The **Protocol Converter** IP converts an AXI4-Stream video interface to an Avalon-ST video interface (or vice versa). This validation design converts a TPG-generated AXI4-Stream and verifies the resulting Avalon-ST frame dimensions match the expected values.

## Validation Configuration

| Parameter              | Value                    |
|------------------------|--------------------------|
| Input Interface        | AXI4-Stream (CCD)        |
| Output Interface       | Avalon-ST                |
| Color Format           | RGB (3 planes)           |
| Bits per Sample        | 8                        |
| Data Width             | 24 bits                  |
