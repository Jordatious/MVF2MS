# Background

This repository contains an MS pulling workflow that uses the SLURM requeue functionality to continually attempt to pull MS data from the SARAO archive via katdal's `mvftoms.py` script. Katdal introduced new functionality with version 0.20.1 to resume the pulling of MS data from a previously incomplete transfer, by taking the last written dump, removing it, and continuing from there. Katdal also introduced additional features to improve the stablility of remote transfers (see issue [here](https://github.com/ska-sa/katdal/issues/362) and pull request [here](https://github.com/ska-sa/katdal/pull/363)). Known issues with this approach are listed below.

# Installing software dependencies

This workflow requires katdal as a software dependency, which can simply be installed following the instructions documented [here](https://docs.google.com/document/d/1Na1Tq6AUHwESaucmG0qcaBAPUcif8637_p4Zah4WU6s/edit#heading=h.lhu2yo6xjrdn). It also requires the `requeue-MS-transfer.sbatch` and `check_data.py` scripts to be in your working directory.

_The script basically relies on `check_data.py` crashing when the MS is incomplete, which only really checks the metadata with CASA's msmd tool. However, msmd is very good at crashing when the MS isn’t intact due to all the data integrity checks it does up-front._

# Running the software

The workflow is run by passing in an RDB link, which is copied to your clipboard when clicking the very left hand icon on the [SARAO archive](https://archive.sarao.ac.za) for the CBID of interest (only shown when data is on disk and not tape), which will be labelled as "32KW", "4KW", "UHF", or similar, like so:

    ./requeue-MS-transfer.sh https://archive-gw-1.kat.ac.za/0123456789/0123456789_sdp_l0.full.rdb?token=blah

After passing in the RDB link as the first argument, the workflow will also take any `mvftoms.py` selection parameters passed in. For example:

    ./requeue-MS-transfer.sh https://archive-gw-1.kat.ac.za/0123456789/0123456789_sdp_l0.full.rdb?token=blah --flags=cam,data_lost -C 0,21591 -p HH,VV -a

Finally, using CBID 1680420378, a full example with the RDB link and its token (now expired) is provided below:

    ./requeue-MS-transfer.sh https://archive-gw-1.kat.ac.za/1680420378/1680420378_sdp_l0.full.rdb?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJpc3MiOiJrYXQtYXJjaGl2ZS5rYXQuYWMuemEiLCJhdWQiOiJhcmNoaXZlLWd3LTEua2F0LmFjLnphIiwiaWF0IjoxNzA2MTU0ODMzLCJwcmVmaXgiOlsiMTY4MDQyMDM3OCJdLCJleHAiOjE3MDY3NTk2MzMsInN1YiI6ImpvcmRhbkBpZGlhLmFjLnphIiwic2NvcGVzIjpbInJlYWQiXX0.iGZuC2RAga8acD0i5cYZCN_6FsOc5vKn9I7uqMjH2Ezn5emtZoB9tkhyyFUzhrpMFBD7BdtYXfUz_wR4g78oEw -f --flags=cam,data_lost -a --chanbin=8 --quack=1

Upon launching the script, the SLURM job name will be updated to `transfer_MS_${CBID}`, a confirmation of the job launching will be output, displaying the CBID, and the email provided in the sbatch header will be emailed when the job starts, ends, fails, and/or hits the 80% time limit (`BEGIN,END,FAIL,TIME_LIMIT_80`).

# Known issues

If the workflow is interrupted, such as timing out, running out of memory, or crashing, it usually leaves the MS in a corrupt state, and any attempts to resume the transfer with katdal with fail. This is as opposed to katdal experiencing a connection issue, and although these are uncommon since the improvements mentioned above, katdal can still resume a transfer following such an error. Some more information and possible future katdal development to get around leaving the MS in a corrupted state is listed [here](https://github.com/ska-sa/katdal/issues/362#issuecomment-1411852385).