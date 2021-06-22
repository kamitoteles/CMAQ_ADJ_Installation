<!-- References  -->
[1]: https://github.com/USEPA/CMAQ/blob/master/DOCS/Users_Guide/Tutorials/CMAQ_UG_tutorial_benchmark.md
[2]: https://docs.gitlab.com/ee/ssh/

# CMAQ installation guide
This guide describes how to use the installation script [install_CMAQ_v5.3.1_Adjoint.sh](install_CMAQ_v5.3.1_Adjoint.sh). All the information in this guide is a compilation of the original [CMAQ 5.3.1 Users Guide][1], the CMAQ Adjoint v.5.0 Wiki and some additional information found in different community forums.

**Disclaimer:** The script and guide on this repository were tested with bash shell on a Linux server system running CentOS 7.4x64 with Intel Paralles XE v.2020.2. All other configurations may need editing the script and systems using other compilers different from the ones Intel provide, may need intense editing of the environment variables and the compiler falgs used.

----

# Installation

```bash
git clone https://github.com/kamitoteles/CMAQ_ADJ_Installation.git
```

# Use

To use, simply run the install_CMAQ_v5.3.1_Adjoint.sh script:

```bash
./install_CMAQ_v5.3.1_Adjoint.sh
```

The installation needs some user input in order to find the compiler paths and edit some installation Makefiles. The guide for each step is shown below:

1. Ones it starts running, you may provide the direct paths to the next listed items in the order that the promt messages appear:

    - **Home directory:** base location where the main folder containing all the model will be created
    - **compilervars.sh; mpivars.sh; and psxevars.sh:** these are the scripts provided with Intel compilers intallation to set up the needed compiler variables. They are commonly found in the /opt/intel/ directory, but depends on where the compilers where installes.
    - **C compiler exectutable** - (eg. /hpfc/user/intel/compiler/bin/mpiicc)
    - **Fotran compiler exectutable** - (eg. /hpfc/user/intel/compiler/bin/mpiifort)
    - **C++ compiler exectutable** - (eg. /hpfc/user/intel/compiler/bin/mpiicpc)

2. In the next step, the script will automatically download and install NetCDF-C 4.7.2 and NetCDF-Fortran 4.5.2. The user soes not need to make anithing in this step.
3. Ones it finish intallung NetCDF, the script will ask the user to edit a series of Make files for the I/OAPI library. The edits for each files are:

    1. Edit the main Makefile. The value of CMAQ_LIBRARIES will be prompted before the file opens. Change the the values as shown here:

        ```bash
        BIN = Linux2_x86_64ifort_intel20.2
        INSTALL = /CMAQ_LIBRARIES
        NCFLIBS = -lnetcdff -lnetcdf
        ```

    2. Edit the Makeinclude file. Use this values:

        ```bash
        FC   = ifort -auto -warn notruncated_source
        OMPFLAGS = -qopenmp
        OMPLIBS = -qopenmp
        .
        .
        .
        ARCHFLAGS = \
        -DIOAPI_NCF4=1 \
        -DAUTO_ARRAYS=1 \
        -DF90=1 -DFLDMN=1 \
        -DFSTR_L=int \
        -DIOAPI_NO_STDOUT=1 \
        -DAVOID_FLUSH=1 -DBIT32=1
        ARCHLIB   =
        ```

    3. Edit ioapi Makefile. The value of CMAQ_LIBRARIES will be prompted before the file opens.

        ```bash
        BASEDIR = /CMAQ_LIBRARIES/ioapi-3.2
        INSTDIR = /CMAQ_LIBRARIES/Linux2_x86_64ifort_intel20.2
        ```

    4. Edit m3tools Makefile. The value of CMAQ_LIBRARIES will be prompted before the file opens.

        ```bash
        BASEDIR = /[CMAQ_LIBRARIES]/ioapi-3.2
        ```

4. On the next step the PARIO and STENEX libraries will be compiled. For this, the user may edit the bldit.se, bldit.se_noop; and bldit.pario scrits with the compilers paths, library paths mpi files, and include files. For this is recomended that the user has a separate terminal tab for checking the location of the components required for each script.

5. Next, the user may enter the private shh key that is connected to the git@adjoint.colorado.edu repository. If the user has no acces to the repository, it may need to contact one of the administrator or search for the public code available. Here is a guide on [how to create and set up and ssh key][2].

6. In the final steps the user may edit the Adjoint configuration and build files. On this files, the user may change the paths for the directories and paths speific for it's system. More description of this process could be found in the Adjoint repository wiki.

# Author

The [install_CMAQ_v5.3.1_Adjoint.sh](install_CMAQ_v5.3.1_Adjoint.sh) and this guide where developed by Camilo Andrés Moreno as part of it's Masters thesis degree proyect. For comments and questions, feel free to remit a message to cama9709@gmail.com.