from pathlib import Path

import h5py
import matplotlib.pyplot as plt
import numpy as np


DATA_DIR = Path(__file__).resolve().parent
LOW_SNR = -10
HIGH_SNR = 20
SYMBOL_COUNT = 1024


SELECTED_MODULATIONS = [
    ("mpsk", 2, "BPSK"),
    ("mpsk", 4, "QPSK"),
    ("mpsk", 8, "8-PSK"),
    ("mpsk", 16, "16-PSK"),
    ("mqam", 16, "16-QAM"),
    ("mqam", 256, "256-QAM"),
    ("mpam", 2, "2-PAM"),
    ("mpam", 16, "16-PAM"),
]

CHANNEL_FILES = {
    "Lognormal": {
        "mpsk": "logn_mpsk_dataset.mat",
        "mqam": "logn_mqam_dataset.mat",
        "mpam": "logn_mpam_dataset.mat",
    },
    "Gamma-Gamma": {
        "mpsk": "gg_mpsk_dataset.mat",
        "mqam": "gg_mqam_dataset.mat",
        "mpam": "gg_mpam_dataset.mat",
    },
}


def dataset_key(mat_file):
    for key, value in mat_file.items():
        if key.endswith("_dataset") and isinstance(value, h5py.Dataset):
            return key
    raise KeyError("No *_dataset matrix found in .mat file.")


def vector(mat_file, key):
    return np.asarray(mat_file[key]).reshape(-1)


def label_for_order(mat_file, modulation_order):
    m_list = vector(mat_file, "M_list").astype(int)
    label_list = vector(mat_file, "label_list").astype(int)

    matches = np.where(m_list == modulation_order)[0]
    if len(matches) == 0:
        raise ValueError(f"M={modulation_order} not available in {mat_file.filename}")

    return int(label_list[matches[0]])


def first_sample_iq(mat_path, modulation_order, snr_db):
    with h5py.File(mat_path, "r") as mat_file:
        key = dataset_key(mat_file)
        data = mat_file[key]
        label = label_for_order(mat_file, modulation_order)

        # MATLAB v7.3 stores this matrix as features x rows.
        snr_row = np.asarray(data[0, :]).reshape(-1)
        label_row = np.asarray(data[-1, :]).reshape(-1).astype(int)
        matches = np.where((snr_row == snr_db) & (label_row == label))[0]

        if len(matches) == 0:
            raise ValueError(
                f"No sample found for M={modulation_order}, label={label}, "
                f"SNR={snr_db} dB in {mat_path.name}"
            )

        sample = np.asarray(data[:, matches[0]]).reshape(-1)
        i_data = sample[1 : 1 + SYMBOL_COUNT]
        q_data = sample[1 + SYMBOL_COUNT : 1 + 2 * SYMBOL_COUNT]
        return i_data, q_data, label


def axis_limit(points):
    max_abs = max(float(np.max(np.abs(values))) for values in points)
    return max(0.05, max_abs * 1.1)


def plot_channel(channel_name, file_map):
    rows = len(SELECTED_MODULATIONS)
    fig, axes = plt.subplots(rows, 2, figsize=(9, 3.0 * rows), constrained_layout=True)
    fig.suptitle(
        f"{channel_name} Constellation Comparison: Low SNR vs High SNR",
        fontsize=16,
        fontweight="bold",
    )

    for row, (family, order, title) in enumerate(SELECTED_MODULATIONS):
        mat_path = DATA_DIR / file_map[family]
        low_i, low_q, label = first_sample_iq(mat_path, order, LOW_SNR)
        high_i, high_q, _ = first_sample_iq(mat_path, order, HIGH_SNR)
        lim = axis_limit([low_i, low_q, high_i, high_q])

        for col, (snr_db, i_data, q_data) in enumerate(
            [(LOW_SNR, low_i, low_q), (HIGH_SNR, high_i, high_q)]
        ):
            ax = axes[row, col]
            ax.scatter(i_data, q_data, s=8, alpha=0.65, edgecolors="none")
            ax.axhline(0, color="0.75", linewidth=0.8)
            ax.axvline(0, color="0.75", linewidth=0.8)
            ax.set_xlim(-lim, lim)
            ax.set_ylim(-lim, lim)
            ax.set_aspect("equal", adjustable="box")
            ax.grid(True, alpha=0.25)
            ax.set_xlabel("In-phase (I)")
            ax.set_ylabel("Quadrature (Q)")
            ax.set_title(f"{title} | label {label} | SNR {snr_db} dB")

    output_path = DATA_DIR / f"constellation_{channel_name.lower().replace('-', '_')}.png"
    fig.savefig(output_path, dpi=1000)
    return output_path


def main():
    saved_files = []
    for channel_name, file_map in CHANNEL_FILES.items():
        saved_files.append(plot_channel(channel_name, file_map))

    print("Saved constellation figures:")
    for output_path in saved_files:
        print(f"  {output_path}")

    plt.show()


if __name__ == "__main__":
    main()
