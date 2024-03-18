#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=50GB
#SBATCH --account=b34-admins-ag
#SBATCH --job-name=transfer_MS_0123456789
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err
#SBATCH --partition=Main
#SBATCH --time=4-00:00:00
#SBATCH --mail-user=my-email@domain.ac.za
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --requeue

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export KATSDPTELSTATE_ALLOW_PICKLE=1

CBID=$1
RDB=$2
echo "$(date) $(hostname): Pulling MS data for CBID ${CBID} (JOBID = ${SLURM_JOB_ID})" >> logs/${CBID}-status.txt

. /idia/users/jcollier/software/katdal-0.21/bin/activate
mvftoms.py -v -u "${@:3}" -o ${CBID}_sdp_l0.ms ${RDB}

TMPOUTFILE=logs/check_${CBID}.out
TMPERRFILE=logs/check_${CBID}.err

srun --time=5 singularity run /idia/software/containers/casa-6.simg ./check_data.py ${CBID}_sdp_l0.ms 1> ${TMPOUTFILE} 2> ${TMPERRFILE}

outcount=$( cat ${TMPOUTFILE} | wc -l )
errcount=$( cat ${TMPERRFILE} | wc -l )

if (( outcount < 5 || errcount > 4 )); then
  echo "$(date) $(hostname): ${TMPOUTFILE} has ${outcount} lines and ${TMPERRFILE} has ${errcount} lines. Resubmitting."
  scontrol requeue $SLURM_JOB_ID
else
  echo "$(date) $(hostname): ${TMPOUTFILE} has ${outcount} lines and ${TMPERRFILE} has ${errcount} lines. Exiting."
fi
