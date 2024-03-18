#!/bin/bash
if [ "$1" = "-h" ]; then
        echo "Input: \$1 - RDB link; \$2+ - MVF to MS config params"
else
	mkdir -p logs
	CBID=$(echo $1 | cut -d '/' -f4)
	sbatch --job-name=transfer_MS_${CBID} requeue-MS-transfer.sbatch $CBID $1 "${@:2}"
	echo "Submitted job for CBID ${CBID}"
fi
