#!/bin/bash
#
########################################
# USER MODIFIABLE PARAMETERS:
 PART=broadwl    # partition name
 TASKS=4         # Set number of cores to use (e.g. 4 cores)
 TIME="4:00:00"  # Set walltime -- (e.g. 4 hours)
 ACCOUNT=""      # PI account to use. If left unset it will use your default account
 QOS=""          # QOS to use. If left unset it will use the default QOS
 PYTHON_MODULE="Anaconda3/2019.03"  # Python module to use -- Anaconda3 dist of python
 CONDA_ENV="mpi4py"    # conda environment name to source. If left unset it will use the base conda
 CONSTRAINT=""   # Set slurm resource constraints. If left unset no constraints applied.
 GRES=""         # Set if using a GPU partition and require use of one or more gpus  (e.g. gpu:1 for one gpu) 
########################################
#
#SET THE PORT NUMBER
PORT_NUM=$(shuf -i8000-9000 -n1)
#
# TRAP SIGINT AND SIGTERM OF THIS SCRIPT
function control_c {
    echo -en "\n SIGINT: TERMINATING SLURM JOBID $JOBID AND EXITING \n"
    scancel $JOBID
    rm jupyter-server.sbatch
    exit $?
}
trap control_c SIGINT
trap control_c SIGTERM
#
# SBATCH FILE FOR ALLOCATING COMPUTE RESOURCES TO RUN NOTEBOOK SERVER
create_sbatch() {
cat << EOF
#!/bin/bash
#
#SBATCH --partition=$PART
#SBATCH --ntasks=$TASKS
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=$TIME
#SBATCH -J nb_server
#SBATCH -o $CWD/session_logs/nb_session_%J.log
EOF
if [ -n "$QOS" ]; then echo "#SBATCH --qos=$QOS" ; fi
if [ -n "$ACCOUNT" ]; then echo "#SBATCH --account=$ACCOUNT" ; fi
if [ -n "$CONSTRAINT" ]; then echo "#SBATCH --constraint=$CONSTRAINT" ; fi
if [ -n "$GRES" ]; then echo "#SBATCH --gres=$GRES" ; fi
cat << EOF
# LOAD A PYTHON MOUDLE WITH JUPYTER
module load $PYTHON_MODULE
EOF
if [ -n "$CONDA_ENV" ]; then
     echo "# "
     echo "# ACTIVATE CONDA ENV "
     echo " source activate $CONDA_ENV"
fi
cat << EOF
#
# TO EXECUTE A NOTEBOOK TO CONNECT TO FROM YOUR LOCAL MACHINE YOU  NEED TO
# GET THE IP ADDRESS OF THE REMOTE MACHINE
export HOST_IP=\`hostname -i\`
launch='jupyter lab --no-browser --ContentsManager.allow_hidden=True --ip=\${HOST_IP} --port $PORT_NUM'
echo "  \$launch "
eval \$launch
EOF
}
#
# CREATE SESSION LOG FOLDER 
if [ ! -d session_logs ] ; then
   mkdir session_logs
fi
#
# CREATE JUPYTER NOTEBOOK SERVER SBATCH FILE
export CWD=`pwd`
create_sbatch > jupyter-server.sbatch
#
# START NOTEBOOK SERVER
#
export JOBID=$(sbatch jupyter-server.sbatch  | awk '{print $4}')
NODE=$(squeue -hj $JOBID -O nodelist )
if [[ -z "${NODE// }" ]]; then
   echo  " "
   echo -n "    WAITING FOR RESOURCES TO BECOME AVAILABLE (CTRL-C TO EXIT) ..."
fi
while [[ -z "${NODE// }" ]]; do
   echo -n "."
   sleep 2
   NODE=$(squeue -hj $JOBID -O nodelist )
done
#
# SLEEP A FEW SECONDS TO ENSURE SLURM JOB HAS SUBMITTED BEFORE WE USE SLURM ENV VARS
  echo -n "."
  sleep 2
NB_ADDRESS=$(grep "] http" session_logs/nb_session_${JOBID}.log | awk -F 'http' '{print $2}' )
  echo -n "."
while [ -z ${NB_ADDRESS} ] ; do 
  sleep 2
  echo -n "."
  NB_ADDRESS=$(grep "] http" session_logs/nb_session_${JOBID}.log | awk -F 'http' '{print $2}' )
done
NB_HOST_NAME=$(squeue -j $JOBID -h -o  %B)
HOST_IP=$(ssh -q $NB_HOST_NAME 'hostname -i')
NB_ADDRESS_INTERNAL=$NB_ADDRESS
NB_ADDRESS_EXTERNAL=$( echo "$NB_ADDRESS"   | sed -e "s/$HOST_IP/localhost/g" )
#NB_ADDRESS=$( echo "$NB_ADDRESS"   | sed -e "s;\\?;lab/tree/master.ipynb\\?;g" )
  TIMELIM=$(squeue -hj $JOBID -O timeleft )
  if [[ $TIMELIM == *"-"* ]]; then
  DAYS=$(echo $TIMELIM | awk -F '-' '{print $1}')
  HOURS=$(echo $TIMELIM | awk -F '-' '{print $2}' | awk -F ':' '{print $1}')
  MINS=$(echo $TIMELIM | awk -F ':' '{print $2}')
  TIMELEFT="THIS SESSION WILL TIMEOUT IN $DAYS DAY $HOURS HOUR(S) AND $MINS MINS "
  else
  HOURS=$(echo $TIMELIM | awk -F ':' '{print $1}' )
  MINS=$(echo $TIMELIM | awk -F ':' '{print $2}')
  TIMELEFT="THIS SESSION WILL TIMEOUT IN $HOURS HOUR(S) AND $MINS MINS "
  fi
  echo " "
  echo "  --------------------------------------------------------------------"
  echo "    STARTING JUPYTER NOTEBOOK SERVER ON NODE $NODE           "
  echo "    $TIMELEFT"
  echo "    SESSION LOG WILL BE STORED IN nb_session_${JOBID}.log  "
  echo "  --------------------------------------------------------------------"
  echo "  "
  echo "    TO ACCESS THIS NOTEBOOK SERVER THERE ARE TWO OPTIONS THAT DEPEND  "
  echo "    ON WHETHER YOU ARE CONNECTED TO THE CAMPUS NETWORK OR NOT         "
  echo "  "
  echo "    IF CONNECTED TO THE CAMPUS NETWORK YOU SIMPLY NEED TO COPY AND    "
  echo "    AND PASTE THE FOLLOWING URL INTO YOUR LOCAL WEB BRWOSER: "
  echo "  "
  echo "    http${NB_ADDRESS_INTERNAL}  "
  echo "  "
  echo "    IF NOT ON THE CAMPUS NETWORK, DO THE FOLLOWING TWO STEPS "
  echo "  "
  echo "    1.) REVERSE TUNNEL FROM YOUR LOCAL MACHINE TO MIDWAY BY COPYING" 
  echo "        AND PASTING THE FOLLOWING SSH COMMAND TO YOUR LOCAL TERMINL"
  echo "        AND EXECUITING IT"
  echo "  "
  echo "     ssh -N -f -L $PORT_NUM:${HOST_IP}:${PORT_NUM} ${USER}@midway2.rcc.uchicago.edu "
  echo "  "
  echo "    2.) THEN LAUNCH THE JUPYTER LAB FROM YOUR LOCAL WEB BROWSER BY "
  echo "        COPYING AND PASTING THE FOLLOWING FULL URL WITH TOKEN INTO"
  echo "        YOUR LOCAL WEB BROWSER: " 
  echo "  "
  echo "    http${NB_ADDRESS_EXTERNAL}  "
  echo "  "
  echo "  --------------------------------------------------------------------"
  echo "    TO KILL THIS NOTEBOOK SERVER ISSUE THE FOLLOWING COMMAND: "
  echo "  "
  echo "       scancel $JOBID "
  echo "  "
  echo "  --------------------------------------------------------------------"
  echo "  "
#
# CLEANUP
  rm jupyter-server.sbatch
#
# EOF

