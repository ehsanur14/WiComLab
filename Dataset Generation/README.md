# MPSK and MQAM Dataset Description

This folder contains the MATLAB scripts and generated MPSK/MQAM datasets for FSO channel classification.

## Files

- `MPSK_Data_Gen.m`: MATLAB script used to generate the MPSK datasets.
- `MQAM_Data_Gen.m`: MATLAB script used to generate the MQAM datasets.
- `gg_mpsk_dataset.mat`: M-PSK dataset generated with Gamma-Gamma turbulence.
- `logn_mpsk_dataset.mat`: M-PSK dataset generated with Lognormal turbulence.
- `gg_mqam_dataset.mat`: M-QAM dataset generated with Gamma-Gamma turbulence.
- `logn_mqam_dataset.mat`: M-QAM dataset generated with Lognormal turbulence.

## Label Encoding

### MPSK

| Modulation | Label |
| --- | ---: |
| BPSK | 0 |
| QPSK | 1 |
| 8-PSK | 2 |
| 16-PSK | 3 |
| 32-PSK | 4 |
| 64-PSK | 5 |
| 128-PSK | 6 |
| 256-PSK | 7 |
| 512-PSK | 8 |
| 1024-PSK | 9 |

### MQAM

| Modulation | Label |
| --- | ---: |
| 4-QAM | 10 |
| 8-QAM | 11 |
| 16-QAM | 12 |
| 32-QAM | 13 |
| 64-QAM | 14 |
| 128-QAM | 15 |
| 256-QAM | 16 |
| 512-QAM | 17 |
| 1024-QAM | 18 |

## Dataset Format

- Samples per SNR: `100`
- Symbol size: `1024`
- SNR range: `-10 dB` to `20 dB` with `2 dB` step
- Total MPSK classes: `10`
- Total MQAM classes: `9`
- Total rows per MPSK dataset: `16000`
- Total rows per MQAM dataset: `14400`
- Total columns per dataset: `2050`

Each row is formatted as:

```text
snr i1 i2 ... i1024 q1 q2 ... q1024 label
```

Dataset matrix sizes:

```text
MPSK: 16000 x 2050
MQAM: 14400 x 2050
```
The first column contains the SNR value in dB. The next `1024` columns contain the in-phase components, followed by `1024` quadrature components. The final column contains the modulation label.
