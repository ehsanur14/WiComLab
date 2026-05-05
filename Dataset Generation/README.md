# MPSK, MQAM, and MPAM Dataset Description

This folder contains the MATLAB scripts and generated MPSK/MQAM/MPAM datasets for FSO channel classification.

## Files

- `MPSK_Data_Gen.m`: MATLAB script used to generate the MPSK datasets.
- `MQAM_Data_Gen.m`: MATLAB script used to generate the MQAM datasets.
- `MPAM_Data_Gen.m`: MATLAB script used to generate the MPAM datasets.
- `gg_mpsk_dataset.mat`: M-PSK dataset generated with Gamma-Gamma turbulence.
- `logn_mpsk_dataset.mat`: M-PSK dataset generated with Lognormal turbulence.
- `gg_mqam_dataset.mat`: M-QAM dataset generated with Gamma-Gamma turbulence.
- `logn_mqam_dataset.mat`: M-QAM dataset generated with Lognormal turbulence.
- `gg_mpam_dataset.mat`: M-PAM dataset generated with Gamma-Gamma turbulence.
- `logn_mpam_dataset.mat`: M-PAM dataset generated with Lognormal turbulence.

## Label Encoding

<table>
  <tr>
    <td valign="top">
      <h3>MPSK</h3>
      <table>
        <tr><th>Modulation</th><th>Label</th></tr>
        <tr><td>BPSK</td><td align="right">0</td></tr>
        <tr><td>QPSK</td><td align="right">1</td></tr>
        <tr><td>8-PSK</td><td align="right">2</td></tr>
        <tr><td>16-PSK</td><td align="right">3</td></tr>
        <tr><td>32-PSK</td><td align="right">4</td></tr>
        <tr><td>64-PSK</td><td align="right">5</td></tr>
        <tr><td>128-PSK</td><td align="right">6</td></tr>
        <tr><td>256-PSK</td><td align="right">7</td></tr>
        <tr><td>512-PSK</td><td align="right">8</td></tr>
        <tr><td>1024-PSK</td><td align="right">9</td></tr>
      </table>
    </td>
    <td valign="top">
      <h3>MQAM</h3>
      <table>
        <tr><th>Modulation</th><th>Label</th></tr>
        <tr><td>4-QAM</td><td align="right">10</td></tr>
        <tr><td>8-QAM</td><td align="right">11</td></tr>
        <tr><td>16-QAM</td><td align="right">12</td></tr>
        <tr><td>32-QAM</td><td align="right">13</td></tr>
        <tr><td>64-QAM</td><td align="right">14</td></tr>
        <tr><td>128-QAM</td><td align="right">15</td></tr>
        <tr><td>256-QAM</td><td align="right">16</td></tr>
        <tr><td>512-QAM</td><td align="right">17</td></tr>
        <tr><td>1024-QAM</td><td align="right">18</td></tr>
      </table>
    </td>
    <td valign="top">
      <h3>MPAM</h3>
      <table>
        <tr><th>Modulation</th><th>Label</th></tr>
        <tr><td>2-PAM</td><td align="right">19</td></tr>
        <tr><td>4-PAM</td><td align="right">20</td></tr>
        <tr><td>8-PAM</td><td align="right">21</td></tr>
        <tr><td>16-PAM</td><td align="right">22</td></tr>
        <tr><td>32-PAM</td><td align="right">23</td></tr>
        <tr><td>64-PAM</td><td align="right">24</td></tr>
        <tr><td>128-PAM</td><td align="right">25</td></tr>
        <tr><td>256-PAM</td><td align="right">26</td></tr>
      </table>
    </td>
  </tr>
</table>

## Dataset Format

- Samples per SNR: `100`
- Symbol size: `1024`
- SNR range: `-10 dB` to `20 dB` with `2 dB` step
- Total MPSK classes: `10`
- Total MQAM classes: `9`
- Total MPAM classes: `8`
- Total rows per MPSK dataset: `16000`
- Total rows per MQAM dataset: `14400`
- Total rows per MPAM dataset: `12800`
- Total columns per dataset: `2050`

Each row is formatted as:

```text
snr i1 i2 ... i1024 q1 q2 ... q1024 label
```

Dataset matrix sizes:

```text
MPSK: 16000 x 2050
MQAM: 14400 x 2050
MPAM: 12800 x 2050
```
The first column contains the SNR value in dB. The next `1024` columns contain the in-phase components, followed by `1024` quadrature components. The final column contains the modulation label.
