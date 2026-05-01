# MPSK Dataset Description

This folder contains the MATLAB script and generated MPSK datasets for FSO channel classification.

## Files

- `MPSK_Data_Gen.m`: MATLAB script used to generate the datasets.
- `gg_mpsk_dataset.mat`: MPSK dataset generated with Gamma-Gamma turbulence.
- `logn_mpsk_dataset.mat`: MPSK dataset generated with Lognormal turbulence.

## Label Encoding

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

## Dataset Format

- Samples per SNR: `100`
- Symbol size: `1024`
- SNR range: `-10 dB` to `20 dB` with `2 dB` step
- Total modulation classes: `10`
- Total rows per dataset: `16000`
- Total columns per dataset: `2050`

Each row is formatted as:

```text
snr i1 i2 ... i1024 q1 q2 ... q1024 label
```

Dataset matrix size:

```text
16000 x 2050
```

The first column contains the SNR value in dB. The next `1024` columns contain the in-phase components, followed by `1024` quadrature components. The final column contains the modulation label.
