 #!/bin/bash
# Editi files function
edit_file() {
    echo -e '--------------------------------------------------------------------------------------------------------------\n'
    echo "Edit the "$1" file"; echo .; sleep 1; echo .; sleep 1; echo .; sleep 1; echo .; sleep 1; echo .; sleep 1
    c=0
    while [ $c -le 1 ]
    do
        vim $1
        wait
        echo -e '--------------------------------------------------------------------------------------------------------------\n'
        read -p 'Did you edited the '${1}' file correctly? ' correct
        if [ $correct != 'Y' ] && [ $correct != 'y' ] && [ $correct != 'YES' ] && [ $correct != 'yes' ] && [ $correct != 'Yes' ]
        then
            echo "Please edit the ${1}"
            sleep 5
        else
            c=2
        fi
    done
}


# Ask the user for the name directory of the installation and the compiler locations
c=0
while [ $c -le 1 ]
do
    read -p 'Enter the home directory ' HOME_D
    read -p 'Enter the Intel compilervars.sh path ' COMP_VARS
    read -p 'Enter the Intel mpivars.sh path '  MPI_VARS
    read -p 'Enter the CC compiler path ' CC
    read -p 'Enter the Fortran compiler path ' FC
    read -p 'Enter the C++ compiler path ' CXX
    export F77=${FC}
    export F90=${FC}

    echo The home directory was set to: $HOME_D
    echo The CC location is set to: $CC
    echo The FC location is set to: $FC
    echo The C++ location is set to: $CXX
    echo The F77 location is set to: $F77

    # Set the compiler libraries
    source "${COMP_VARS}" -arch intel64 -platform linux
    source "${MPI_VARS}"
    source /hpcfs/home/ca.moreno12/intel/parallel_studio_xe_2020/psxevars.sh
    echo -e "\n The PATH is \n"
    echo $PATH

    echo -e "\n The LD_LIBRARY_PATH is \n"
    echo $LD_LIBRARY_PATH

    echo -e '--------------------------------------------------------------------------------------------------------------\n'
    read -p 'Are those the correct locations? ' correct

    if [ $correct != 'Y' ] && [ $correct != 'y' ] && [ $correct != 'YES' ] && [ $correct != 'yes' ] && [ $correct != 'Yes' ]
    then
        echo -e "\n Please enter the correct locations \n"
    else
        c=2
    fi
done


set echo
# Set the home CMAQ directory
cd ${HOME_D}
mkdir CMAQ_v5.3.1
cd CMAQ_v5.3.1
mkdir LIBRARIES
export CMAQ_HOME=${PWD}
export CMAQ_LIBRARIES=${CMAQ_HOME}/LIBRARIES
cd ${CMAQ_LIBRARIES}

# Install netCDF-C
wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-c-4.7.2.tar.gz;wait
tar -xzvf netcdf-c-4.7.2.tar.gz;wait
rm netcdf-c-4.7.2.tar.gz
cd netcdf-c-4.7.2
mkdir ../netcdf-c-4.7.2-intel20.2
./configure --prefix=${CMAQ_LIBRARIES}/netcdf-c-4.7.2-intel20.2 --disable-netcdf-4 --disable-dap; wait
make check install |& tee make.install.log.txt; wait
cd ${CMAQ_LIBRARIES}
export NCDIR=${CMAQ_LIBRARIES}/netcdf-c-4.7.2-intel20.2
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${NCDIR}/lib
export PATH=${PATH}:${NCDIR}/bin

# Install netCDF-Fortran
wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.5.2.tar.gz;wait 
tar -xzvf netcdf-fortran-4.5.2.tar.gz; wait
rm netcdf-fortran-4.5.2.tar.gz
cd netcdf-fortran-4.5.2
mkdir ${CMAQ_LIBRARIES}/netcdf-fortran-4.5.2-intel20.2
export NFDIR=${CMAQ_LIBRARIES}/netcdf-fortran-4.5.2-intel20.2
export CPPFLAGS="${CPPFLAGS} -I${NCDIR}/include"
export LDFLAGS="${LDFLAGS} -L${NCDIR}/lib"

./configure --prefix=${NFDIR}; wait
make check |& tee make.check.log.txt; wait
make install |& tee ./make.install.log.txt; wait

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${NFDIR}/lib
export PATH=${PATH}:${NFDIR}/bin
cd ${CMAQ_LIBRARIES}

# Install I/O API
git clone https://github.com/cjcoats/ioapi-3.2; wait
cd ioapi-3.2
git checkout -b 20200828
cp Makefile.template Makefile
echo -e "CMAQ_LIBRARIES = ${CMAQ_LIBRARIES}\n"

edit_file Makefile

cd ioapi
cp Makeinclude.Linux2_x86_64ifort Makeinclude.Linux2_x86_64ifort_intel20.2
echo -e "CMAQ_LIBRARIES = ${CMAQ_LIBRARIES}\n"

edit_file Makeinclude.Linux2_x86_64ifort_intel20.2

cp Makefile.nocpl Makefile
echo -e "CMAQ_LIBRARIES = ${CMAQ_LIBRARIES}\n"

edit_file Makefile

cd ../m3tools
cp Makefile.nocpl Makefile
echo -e "CMAQ_LIBRARIES = ${CMAQ_LIBRARIES}\n"

edit_file Makefile

cd ..
export BIN=Linux2_x86_64ifort_intel20.2
mkdir $BIN
cd $BIN
ln -s ${CMAQ_LIBRARIES}/netcdf-c-4.7.2-intel20.2/lib/libnetcdf.a
ln -s ${CMAQ_LIBRARIES}/netcdf-fortran-4.5.2-intel20.2/lib/libnetcdff.a
cd ..

make all |& tee make.log; wait

cp ${BIN}/*.mod ${CMAQ_LIBRARIES}/ioapi-3.2/ioapi/fixed_src; wait
cp ${BIN}/*.h ${CMAQ_LIBRARIES}/ioapi-3.2/ioapi/fixed_src; wait

mkdir Linux2_x86_64ifort_intel_whithoutsoftlinks
cp ${BIN}/* Linux2_x86_64ifort_intel_whithoutsoftlinks;wait

unlink Linux2_x86_64ifort_intel_whithoutsoftlinks/libnetcdf.a
unlink Linux2_x86_64ifort_intel_whithoutsoftlinks/libnetcdff.a

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${CMAQ_LIBRARIES}/ioapi-3.2/Linux2_x86_64ifort_intel_whithoutsoftlinks
cd ${CMAQ_HOME}

# Install CMAQ-5.3.1
git clone -b master https://github.com/USEPA/CMAQ.git CMAQ_REPO;wait
cd ${CMAQ_HOME}/CMAQ_REPO
git checkout -b my_branch

edit_file bldit_project.csh
./bldit_project.csh;wait

cd ${CMAQ_HOME}

edit_file config_cmaq.csh
./config_cmaq.csh intel; wait


# Pario and stenex libs
#! EDITAR IOAPI PARAMS para quitarle la &
cd ${CMAQ_LIBRARIES}/ioapi-3.2/ioapi/fixed_src
edit_file PARMS3.EXT

cd ${CMAQ_HOME}
mkdir PARIO_v4.7.1 STENEX_v4.7.1

git clone -b 4.7.1 https://github.com/USEPA/CMAQ.git CMAQ_v4.7.1;wait

mkdir ${CMAQ_HOME}/CMAQ_v4.7.1/lib
mkdir ${CMAQ_HOME}/CMAQ_v4.7.1/data

export M3HOME=${CMAQ_HOME}/CMAQ_v4.7.1
export M3MODEL=${CMAQ_HOME}/CMAQ_v4.7.1/models
export M3LIB=${CMAQ_HOME}/CMAQ_v4.7.1/lib
export M3DATA=${CMAQ_HOME}/CMAQ_v4.7.1/data

mkdir ${M3LIB}/build
mkdir ${M3LIB}/ioapi_3
mkdir ${M3LIB}/netCDF
mkdir ${M3LIB}/pario 
mkdir ${M3LIB}/stenex

cd ${M3LIB}/netCDF 

ln -s ${CMAQ_LIBRARIES}/netcdf-c-4.7.2-intel20.2/lib/libnetcdf.a
ln -s ${CMAQ_LIBRARIES}/netcdf-fortran-4.5.2-intel20.2/lib/libnetcdff.a

cp ${CMAQ_LIBRARIES}/ioapi-3.2/Linux2_x86_64ifort_intel_whithoutsoftlinks/* ${M3LIB}/ioapi_3;wait

cd ${M3HOME}/scripts/stenex

edit_file bldit.se
./bldit.se  |& tee bldit.se.log;wait

edit_file bldit.se_noop
./bldit.se_noop  |& tee bldit.se_noop.log;wait

cd ${M3HOME}/scripts/pario

edit_file bldit.pario
./bldit.pario  |& tee bldit.pario.log;wait


# Adjoint
eval $(ssh-agent)
echo -e '--------------------------------------------------------------------------------------------------------------\n'
read -p 'Enter your ssh key path which is connected to the adjoint repository: ' SSHKEYADJ
ssh-add ${SSHKEYADJ}

git clone ssh://git@adjoint.colorado.edu/yanko.davila/cmaq_adj.git;wait
git checkout -b test origin/gas

cd cmaq_adj
export CMAQ_ADJ_HOME=${PWD}
edit_file config.cmaq

cd ${CMAQ_ADJ_HOME}/BLDMAKE_git
edit_file Makefile
make |& tee make.bld.log;wait

cd ${CMAQ_ADJ_HOME}/scripts
cp bldit.adjoint.fwd.sample bldit.adjoint.fwd.intel
edit_file bldit.adjoint.fwd.intel
./bldit.adjoint.fwd.intel |& tee bldit.fwd.log;wait

cd ${CMAQ_ADJ_HOME}/BLD_fwd_bnmk
edit_file Makefile
make |& tee make.bld.log;wait

cd ${CMAQ_ADJ_HOME}/scripts
cp bldit.adjoint.bwd.sample bldit.adjoint.bwd.intel
edit_file bldit.adjoint.bwd.intel
./bldit.adjoint.bwd.intel |& tee bldit.bwd.log;wait

cd ${CMAQ_ADJ_HOME}/BLD_bwd
edit_file Makefile
make |& tee make.bld.log;wait

