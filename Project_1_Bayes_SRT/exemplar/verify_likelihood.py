#!/usr/bin/env python3
"""Independent read-only likelihood check for the archived ex-Gaussian sample.

Not a MultiNest rerun, evidence check, HPC rebuild or public-release clearance.
Requires: numpy, scipy, h5py. Usage: python verify_likelihood.py
"""
from pathlib import Path
import re
import numpy as np
import h5py
from scipy.stats import exponnorm

HERE = Path(__file__).resolve().parent
with h5py.File(HERE / 'data' / 'subject-11_model-exgauss.mat', 'r') as data_file:
    rt = np.asarray(data_file['RTs'], dtype=float).reshape(-1)
post = np.loadtxt(HERE / 'results' / 'exgauss-mom-sim250_post_equal_weights.dat')
assert rt.shape == (250,), f'Expected 250 simulated reaction times, got {rt.shape}'
assert post.shape == (4322, 4), f'Unexpected archived chain shape {post.shape}'
assert np.all(np.isfinite(rt)) and np.all(np.isfinite(post))
mu, sigma, tau, reported = post.T
assert np.all(sigma > 0) and np.all(tau > 0)
# SciPy's exponnorm shape K = mean exponential tau / Gaussian sd sigma.
# Broadcast parameter rows x all 250 independently observed trials.
recomputed = exponnorm.logpdf(
    rt[np.newaxis, :],
    K=(tau / sigma)[:, np.newaxis],
    loc=mu[:, np.newaxis],
    scale=sigma[:, np.newaxis],
).sum(axis=1)
err = np.max(np.abs(recomputed - reported))
print('Dataset: 250 simulated RT observations; subject 11, ex-Gaussian model')
print(f'RT mean: {rt.mean():.9f}; population sd: {rt.std():.9f}')
print(f'RT range: [{rt.min():.9f}, {rt.max():.9f}]')
print(f'Posterior rows checked: {post.shape[0]}')
print(f'Maximum absolute saved vs recomputed log-likelihood difference: {err:.17g}')
for i, name in enumerate(('mu', 'sigma', 'tau')):
    mean = post[:, i].mean()
    low, high = np.quantile(post[:, i], [0.025, 0.975])
    print(f'{name}: posterior mean {mean:.5f}; 2.5%-97.5% quantiles [{low:.5f}, {high:.5f}]')
text = (HERE / 'results' / 'exgauss-mom-sim250_stats.dat').read_text(errors='replace')
m = re.search(r'Nested Sampling Global Log-Evidence\s*:\s*([+\-\d.Ee]+)\s*\+/-\s*([+\-\d.Ee]+)', text)
if m:
    print(f'Archived global log evidence: {float(m.group(1)):.9f} +/- {float(m.group(2)):.9f}')
else:
    print('Could not locate evidence line in archived stats file')
assert err < 1e-8, 'FAIL: archived log-likelihoods differ materially from analytic values'
print('PASS: archived reaction times / posterior log-likelihoods are numerically consistent')
