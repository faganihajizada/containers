#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (C) SchedMD LLC.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

# Liveness probe: verifies slurmd health and node registration.
# Passes if controller unreachable (avoid disrupting running jobs).

# Check if slurmd is responsive locally
if ! scontrol show slurmd >/dev/null 2>&1; then
	echo "slurmd is not responsive locally, failing probe"
	exit 1
fi

# Check if node is registered with controller
if ! OUTPUT=$(timeout 10s scontrol show node "$(hostname)" --json 2>&1); then
	echo "scontrol failed, passing probe (controller may be down)"
	exit 0
fi

if echo "$OUTPUT" | grep -q '"nodes": \[\]'; then
	echo "node not registered with slurm controller, failing probe"
	exit 1
fi

exit 0
