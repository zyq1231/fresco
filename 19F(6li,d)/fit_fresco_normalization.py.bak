#!/usr/bin/env python3
"""Fit a multiplicative normalization to FRESCO differential cross sections.

The fitted model is

    sigma_exp(theta_i) = C * sigma_FRESCO(theta_i),

where the FRESCO curve is linearly interpolated to the experimental angles.
For weighted least squares,

    C = sum(w_i * exp_i * theory_i) / sum(w_i * theory_i**2).

Input theory files may be whitespace- or comma-separated. Non-numeric header
lines are ignored. By default, the first and second numeric columns are read as
angle (degrees) and differential cross section (mb/sr).
"""

from __future__ import annotations

import argparse
import csv
import math
import re
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class ExperimentalPoint:
    angle: float
    value: float
    uncertainty: float | None


def finite_float(text: str | None) -> float | None:
    if text is None or not text.strip():
        return None
    try:
        value = float(text)
    except ValueError:
        return None
    return value if math.isfinite(value) else None


def read_experiment(
    path: Path,
    excitation: float,
    excitation_tolerance: float,
    relative_uncertainty: float | None,
) -> list[ExperimentalPoint]:
    points: list[ExperimentalPoint] = []
    with path.open(newline="", encoding="utf-8-sig") as stream:
        reader = csv.DictReader(stream)
        required = {"Ex_MeV", "theta_cm_deg", "dsdo_mb_sr"}
        if not reader.fieldnames or not required.issubset(reader.fieldnames):
            raise ValueError(f"Experimental CSV must contain: {sorted(required)}")

        for row in reader:
            ex = finite_float(row.get("Ex_MeV"))
            angle = finite_float(row.get("theta_cm_deg"))
            value = finite_float(row.get("dsdo_mb_sr"))
            if ex is None or angle is None or value is None:
                continue
            if abs(ex - excitation) > excitation_tolerance:
                continue

            low = finite_float(row.get("dsdo_low_mb_sr"))
            high = finite_float(row.get("dsdo_high_mb_sr"))
            uncertainty = None
            if low is not None and high is not None and high > low:
                uncertainty = 0.5 * (high - low)
            elif relative_uncertainty is not None:
                uncertainty = relative_uncertainty * value

            points.append(ExperimentalPoint(angle, value, uncertainty))

    if not points:
        raise ValueError(f"No experimental points found for Ex={excitation:g} MeV")
    return sorted(points, key=lambda point: point.angle)


def numeric_columns(line: str) -> list[float]:
    """Return finite numeric tokens from a comma/whitespace-separated line."""
    values: list[float] = []
    for token in re.split(r"[\s,;]+", line.strip()):
        if not token:
            continue
        # Accept Fortran D exponents.
        token = token.replace("D", "E").replace("d", "e")
        try:
            value = float(token)
        except ValueError:
            continue
        if math.isfinite(value):
            values.append(value)
    return values


def read_theory(path: Path, angle_column: int, cross_column: int) -> list[tuple[float, float]]:
    points: list[tuple[float, float]] = []
    needed = max(angle_column, cross_column)
    with path.open(encoding="utf-8", errors="ignore") as stream:
        for line in stream:
            values = numeric_columns(line)
            if len(values) <= needed:
                continue
            angle = values[angle_column]
            cross_section = values[cross_column]
            if 0.0 <= angle <= 180.0 and cross_section >= 0.0:
                points.append((angle, cross_section))

    # Sort and average duplicate angles, which can occur in verbose outputs.
    grouped: dict[float, list[float]] = {}
    for angle, value in points:
        grouped.setdefault(angle, []).append(value)
    curve = sorted((angle, sum(vals) / len(vals)) for angle, vals in grouped.items())
    if len(curve) < 2:
        raise ValueError(
            "Could not find at least two theory points. Check --angle-column and "
            "--cross-column (columns are zero-based)."
        )
    return curve


def interpolate(curve: list[tuple[float, float]], angle: float, log_y: bool) -> float | None:
    if angle < curve[0][0] or angle > curve[-1][0]:
        return None
    for (x0, y0), (x1, y1) in zip(curve, curve[1:]):
        if x0 <= angle <= x1:
            if angle == x0 or x1 == x0:
                return y0
            fraction = (angle - x0) / (x1 - x0)
            if log_y and y0 > 0.0 and y1 > 0.0:
                return math.exp(math.log(y0) + fraction * (math.log(y1) - math.log(y0)))
            return y0 + fraction * (y1 - y0)
    return curve[-1][1] if angle == curve[-1][0] else None


def fit_scale(
    experiment: list[ExperimentalPoint],
    theory: list[tuple[float, float]],
    log_interpolation: bool,
    unweighted: bool,
) -> tuple[float, list[tuple[ExperimentalPoint, float, float]]]:
    matched: list[tuple[ExperimentalPoint, float, float]] = []
    numerator = 0.0
    denominator = 0.0

    for point in experiment:
        theory_value = interpolate(theory, point.angle, log_interpolation)
        if theory_value is None:
            continue
        weight = 1.0
        if not unweighted and point.uncertainty is not None and point.uncertainty > 0.0:
            weight = 1.0 / point.uncertainty**2
        numerator += weight * point.value * theory_value
        denominator += weight * theory_value**2
        matched.append((point, theory_value, weight))

    if not matched:
        raise ValueError("No experimental angles lie inside the FRESCO angular range")
    if denominator <= 0.0:
        raise ValueError("Theory cross sections are zero at all matched experimental angles")
    return numerator / denominator, matched


def fit_statistics(
    scale: float,
    matched: list[tuple[ExperimentalPoint, float, float]],
) -> dict[str, float]:
    residual_sum = 0.0
    chi_square = 0.0
    for point, theory_value, weight in matched:
        residual = point.value - scale * theory_value
        residual_sum += residual**2
        chi_square += weight * residual**2
    n = len(matched)
    return {
        "n": float(n),
        "rmse": math.sqrt(residual_sum / n),
        "chi2": chi_square,
        "reduced_chi2": chi_square / max(n - 1, 1),
    }


def write_scaled_curve(path: Path, theory: list[tuple[float, float]], scale: float) -> None:
    with path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.writer(stream)
        writer.writerow(["theta_cm_deg", "fresco_mb_sr", "scaled_mb_sr"])
        for angle, value in theory:
            writer.writerow([f"{angle:.10g}", f"{value:.10g}", f"{scale * value:.10g}"])


def write_comparison(
    path: Path,
    matched: list[tuple[ExperimentalPoint, float, float]],
    scale: float,
) -> None:
    with path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.writer(stream)
        writer.writerow([
            "theta_cm_deg", "experiment_mb_sr", "uncertainty_mb_sr",
            "fresco_mb_sr", "scaled_mb_sr", "residual_mb_sr",
        ])
        for point, theory_value, _ in matched:
            scaled = scale * theory_value
            writer.writerow([
                f"{point.angle:.10g}", f"{point.value:.10g}",
                "" if point.uncertainty is None else f"{point.uncertainty:.10g}",
                f"{theory_value:.10g}", f"{scaled:.10g}", f"{point.value - scaled:.10g}",
            ])


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Fit one normalization coefficient to FRESCO differential cross sections."
    )
    parser.add_argument("experiment", type=Path, help="Digitized experimental CSV")
    parser.add_argument("theory", type=Path, help="FRESCO angle/cross-section text file")
    parser.add_argument("--ex", type=float, required=True, help="Excitation energy to select, MeV")
    parser.add_argument(
        "--ex-tolerance", type=float, default=0.005,
        help="Allowed excitation-energy difference, MeV (default: 0.005)",
    )
    parser.add_argument(
        "--angle-column", type=int, default=0,
        help="Zero-based angle column among numeric tokens (default: 0)",
    )
    parser.add_argument(
        "--cross-column", type=int, default=1,
        help="Zero-based cross-section column among numeric tokens (default: 1)",
    )
    parser.add_argument(
        "--relative-uncertainty", type=float, default=0.15,
        help="Relative uncertainty for points without error bars (default: 0.15)",
    )
    parser.add_argument(
        "--unweighted", action="store_true",
        help="Minimize unweighted squared residuals instead of chi-square",
    )
    parser.add_argument(
        "--linear-interpolation", action="store_true",
        help="Interpolate cross sections linearly instead of logarithmically",
    )
    parser.add_argument(
        "--scaled-output", type=Path, default=Path("scaled_fresco.csv"),
        help="Output CSV for the full scaled FRESCO curve",
    )
    parser.add_argument(
        "--comparison-output", type=Path, default=Path("fit_comparison.csv"),
        help="Output CSV comparing theory and experiment at measured angles",
    )
    args = parser.parse_args()

    if args.relative_uncertainty <= 0.0:
        parser.error("--relative-uncertainty must be positive")
    if args.angle_column < 0 or args.cross_column < 0:
        parser.error("column indices must be non-negative")

    experiment = read_experiment(
        args.experiment, args.ex, args.ex_tolerance, args.relative_uncertainty
    )
    theory = read_theory(args.theory, args.angle_column, args.cross_column)
    scale, matched = fit_scale(
        experiment, theory, not args.linear_interpolation, args.unweighted
    )
    statistics = fit_statistics(scale, matched)

    write_scaled_curve(args.scaled_output, theory, scale)
    write_comparison(args.comparison_output, matched, scale)

    print(f"Excitation energy : {args.ex:g} MeV")
    print(f"Matched points    : {int(statistics['n'])}")
    print(f"Best scale C      : {scale:.10g}")
    print(f"RMSE              : {statistics['rmse']:.10g} mb/sr")
    print(f"chi-square        : {statistics['chi2']:.10g}")
    print(f"reduced chi-square: {statistics['reduced_chi2']:.10g}")
    print(f"Scaled curve      : {args.scaled_output}")
    print(f"Point comparison  : {args.comparison_output}")


if __name__ == "__main__":
    main()
