nicam-dc-mini
=============

* version: 1.0.0 (based on NICAM-DC_20130823.tgz version)
* date: 2014/07/07
* contact: miniapp@riken.jp


About nicam-dc-mini and NICAM-DC
--------------------------------
Nicam-dc-mini is a subset of NICAM-DC application, and it contains
the minimum computational procedures to run baroclinic wave test case
(Jablonowski and Williamson, 2006) which is a well-known benchmark of
atmospheric general circulation model reproducing the unsteady baroclinic
oscillation.
As such, it retains the same computational workload characteristics as
NICAM-DC, while enabling the performance evaluation in compact manner.
Further information regarding NICAM-DC is provided in the later
section of this readme document.



Installation
------------

###quick example - K computer
As a quick start, the installation example on K computer is shown first.

    $ MY_DIR=$PWD
    $ tar -zxf nicam-dc-mini.ver1.tar.gz
    $ export NICAM_SYS=K
    $ cd $MY_DIR/nicam-dc-mini/src
    $ make
    $ cd $MY_DIR/nicam-dc-mini/test/case/jablonowski
    $ make
    $ make jobshell
    $ make run

###Installation steps on general Linux platform
The installation steps of nicam-dc-mini on Linux based platform are explained
below.
If your platform is covered by one of the prepared scripts in this package,
the installation can be as simple as above K computer example.
If this is not the case, you may need to take an extra step (step 2A),
which should not be very complicated as well.

The following software must be available on that platform.

+ Prerequisite software:
  - Fortran and C compiler
  - MPI library,

####step 1. Obtain the distribution package.

Obtain the nicam-dc-mini package file "nicam-dc-mini.ver1.tar.gz" from
the repository.  
https://github.com/fiber-miniapp/nicam-dc-mini  
Extract its contents using tar command.
This readme file (readme.md) is included in the package.

    $ MY_DIR=$PWD
    $ tar -zxf nicam-dc-mini.ver1.tar.gz
    $ cd ${MY_DIR}/nicam-dc-mini
    $ ls -CF
    LICENSE  NICAM-DC_LOGO.png  README.md
    bin/  data/  lib/  src/  sysdep/  test/


####step 2.  Choose the installing platform.

In sysdep/ directory, there are a number of Makedef.* files for different platforms.

If your installing platform is covered by one of these Makedef.* files,
then simply set NICAM_SYS environment variable using the chosen value,
and proceed to step 3.
Below is an example for Linux64-intel-impi (Intel compiler + Intel MPI) platform.

    $ cd ${MY_DIR}/nicam-dc-mini/sysdep
    $ ls Makedef.*
    Makedef.ES2   Makedef.Linux64-gnu-ompi      Makedef.Linux64-pgi-mpich2
    Makedef.FX10  Makedef.Linux64-intel-impi    Makedef.Linux64-pgiacc-mpich2
    Makedef.K     Makedef.Linux64-intel-mpich2  Makedef.MacOSX-gnu-ompi
    $ export NICAM_SYS=Linux64-intel-impi
    $ file Makedef.${NICAM_SYS}
    Makedef.Linux64-intel-impi: ASCII make commands text

You can skip to step 3, if the installing platform is covered by one of
above Makedef.* files, like above.

If your testing platform is NOT covered by above Makedef.* files, then follow
step 2A and create the necessary Makedef and Mkjobshell files.

####step 2A. (This step is needed only if your platform is not covered by the package)

Decide your platform name and set it as NICAM_SYS environment variable.
Edit the contents of Makedef.${NICAM_SYS} and Mkjobshell.${NICAM_SYS} .
Most likely, you will need to change the values of: MPIEXEC command
name, the first several lines of here document run.sh, ico2ll.sh.
Your mileage may vary, although this step should not be very complicated.
Below in an example of creating MYPC platform from the copy of other platform.

    $ export NICAM_SYS=MYPC
    $ cp Makedef.Linux64-intel-impi Makedef.${NICAM_SYS}
    $ cp Mkjobshell.Linux64-intel-impi Mkjobshell.${NICAM_SYS}
    $ vi Makedef.${NICAM_SYS} Mkjobshell.${NICAM_SYS}

If your platform supports module command for choosing the programming
environment dynamically, it often makes it easier to simplify the Makedef,
and is recommended to take advantage of it.

####step 3. Compile the source programs.

Compile time varies a lot depending on your platform.
Some platforms support parallel make which can reduce your wait time.
In such case you can try parallel "make -j 8" , instead of "make" below.

    $ module load intel impi
    $ cd ${MY_DIR}/nicam-dc-mini/src
    $ make


####step 4. Prepare the test job.

Set up the job script file for jablonowski test case.

    $ cd ${MY_DIR}/nicam-dc-mini/test/case/jablonowski
    $ make
    $ make jobshell


Running the jablonowski test case
--------------------

When the installation step 4 is finished, the job script file for
jablonowski test case should have been created as "run.sh".
By default, the run.sh script assumes 10 nodes (10 MPI) for the job.
Check the contents of run.sh, and execute it in batch, or interactively.
Submitting a batch job to the available job manager depends on the platform.
Below in an example of running the test job on K computer.

    $ cd ${MY_DIR}/nicam-dc-mini/test/case/jablonowski/gl05rl00z40pe10/
    $ pjsub run.sh

The job runs the model that is configured by test.conf file.
The default test.conf file contains the following values.
The meaning of the parameters will be explained in the next section.

    glevel = 5
    rlevel = 0
    nmpi   = 10
    zlayer = 40
    vgrid  = vgrid40_24000-600m.dat
    LSMAX  = 0
    DTL    = 1200
    DIFCF  = '1.29D16'
    NHIST  = 0

It takes 2 minutes on K computer, and 5 minutes on a Intel Xeon E5 cluster.
After successful run, the directory should contain the result files.
The standard output file, run.sh.o38787 in this case, should show its last lines as:

    $ ls
    ENERGY_BUDGET.info          history.pe000005  prof
    MASS_BUDGET.info            history.pe000006  restart_all_GL05RL00z40.pe000000
    boundary_GL05RL00.pe000000  history.pe000007  restart_all_GL05RL00z40.pe000001
    boundary_GL05RL00.pe000001  history.pe000008  restart_all_GL05RL00z40.pe000002
    boundary_GL05RL00.pe000002  history.pe000009  restart_all_GL05RL00z40.pe000003
    boundary_GL05RL00.pe000003  ico2ll.sh         restart_all_GL05RL00z40.pe000004
    boundary_GL05RL00.pe000004  msg.pe00000       restart_all_GL05RL00z40.pe000005
    boundary_GL05RL00.pe000005  msg.pe00001       restart_all_GL05RL00z40.pe000006
    boundary_GL05RL00.pe000006  msg.pe00002       restart_all_GL05RL00z40.pe000007
    boundary_GL05RL00.pe000007  msg.pe00003       restart_all_GL05RL00z40.pe000008
    boundary_GL05RL00.pe000008  msg.pe00004       restart_all_GL05RL00z40.pe000009
    boundary_GL05RL00.pe000009  msg.pe00005       rl00-prc10.info
    diagvar.info                msg.pe00006       run.sh
    history.pe000000            msg.pe00007       run.sh.i38787
    history.pe000001            msg.pe00008       run.sh.o38787
    history.pe000002            msg.pe00009       vgrid40_24000-600m.dat
    history.pe000003            nhm_driver
    history.pe000004            nhm_driver.cnf

    $ tail -3 run.sh.o38787
    ### TIME = 0000/01/11-23:40:00 ( step =  791  )
    ### TIME = 0000/01/12-00:00:00 ( step =  792  )
    ##### finish main loop #####



###Input files
The input files and their contents are as below.

* nhm_driver.cnf         : run configuration file @ test/case/jablonowski/gl05rl00z40pe10/nhm_driver.cnf
* rl00-prc05.info        : process management file @ data/mnginfo/rl00-prc05.info
* boundary_GL05RL00.pe*  : horizontal grid file @ data/grid/boundary/gl05rl00pe10/boundary_GL05RL00.pe000000
* vgrid80_24000-300m.dat : vertical grid file @ data/grid/vgrid/vgrid80_24000-300m.dat

###Output files
The output files and their contents are as below.

* msg.pe*                     : log file
* history.pe*                 : history output file
* ENERGY_BUDGET.info          : energy budget information file
* MASS_BUDGET.info            : mass budget information file
* restart_all_GL05RL00z80.pe* : restart file
* diagvar.info                : not in use

###Verifying the computed results

The msg.* file should contain the summary of prognostic variables.
Check the values of msg.pe00000 and see if they match the values below
up to reasonable digits.

    $ sed -n "/prognostic variables/,+5p" msg.pe00000 | tail -6
    ====== data range check : prognostic variables ======
    --- pre             : max= 9.85041585433862347E+04, min= 2.74551688200134413E+03
    --- tem             : max= 3.08688864513657961E+02, min= 2.09192046390859161E+02
    --- vx              : max= 4.15678669078258594E+01, min=-3.52888677115836060E+01
    --- vy              : max= 3.53899527668479834E+01, min=-3.54272171873004353E+01
    --- vz              : max= 1.34172829773123254E+01, min=-1.41486318063738015E+01

They should also contain "normally finished." in the last line.

The computed grid values are saved in "history.pe*" binary files.
If needed additionally, check the values in "history.000000" files using
fio_dump command.

    $ ${MY_DIR}/nicam-dc-mini/bin/fio_dump -d history.pe000000 >stdout.00


###How to change the simulation time

The default test case is 11 day simulation with 224 Km horizontal grid spacing
and 20 minutes delta t.
To reduce the run time length, the number of time steps can be changed
via LSMAX parameter in the test/test.conf file as follows;

LSMAX  = 0 (=auto:792)→ LSMAX  = 396 or 264



Running the scalability tests
-----------------------------

In NICAM-DC, total problem size is determined by grid division level (glevel)
and vertical layer (zlayer). The problem size for each MPI process
depends on the region division level (rlevel) and the number of MPI processes.
Their relationship is explained later in this section.


To run the scalability tests, it is necessary to install the additional
binary data files and their configuration files.
As of this version, the weak scalability test data files for the following jobs
have been made available:  
10, 40, 160, 640, 2560 MPI processes.  
These data files and configuration files are archived as a tar ball at:  

http://hpci-aplfs.aics.riken.jp/fiber/nicam-dc-mini/data-weak2560.tar.gz

Download this file and install it on the top directory as follows:

    $ cd ${MY_DIR}/nicam-dc-mini
    $ # copy the downloaded tar ball to here
    $ tar -zxf data-weak2560.tar.gz

For each of the scalability job, the problem configuration must be set,
and the test directory must be created.
The problem configuration is set through the values of "test.conf" file
located in test/ directory.
Repeating the step 4 in the above installation chapter will create
the corresponding test directory.

The configuration files for 10, 40, 160, 640, 2560 MPI processes are
included in the "data-weak2560.tar.gz" file, and they should be
found under test/config sub directory.

To prepare a 160 MPI process job, for example, it can be done as follows.

    $ cd ${MY_DIR}/nicam-dc-mini/test
    $ ls config
    test.conf.gl05rl00z80pe10
    test.conf.gl06rl01z80pe40
    test.conf.gl07rl02z80pe160
    test.conf.gl08rl03z80pe640
    test.conf.gl09rl04z80pe2560
    $ cp config/test.conf.gl07rl02z80pe160 test.conf
    $ # Take the same procedure as step 4 in the installation chapter
    $ cd ${MY_DIR}/nicam-dc-mini/test/case/jablonowski
    $ make          # The same as step 4.
    $ make jobshell # The same as step 4.

A directory named gl07rl02z80pe160 containing the test configuration
and the job script should be created.
The name of the test directory is decided according to the value of
glevel, rlevel, zlayer, nmpi as follows:

    "gl${glevel}rl${rlevel}z${zlayer}pe${PEs}".

After repeating this for each of the test.conf file, there should be
5 directories created as below.

    |glevel |zlayer |rlevel | nmpi  |  test directory   |
    |:-----:|:-----:|:-----:|:-----:|:-----------------:|
    | 5     | 80    | 0     | 10    | gl05rl00z80pe10   |
    | 6     | 80    | 1     | 40    | gl06rl01z80pe40   |
    | 7     | 80    | 2     | 160   | gl07rl02z80pe160  |
    | 8     | 80    | 3     | 640   | gl08rl03z80pe640  |
    | 9     | 80    | 4     | 2560  | gl09rl04z80pe2560 |

The scalability tests can be run simultaneously on each of the test directories.


In general, running the scalability tests with various configuration can be
accomplished through changing the values of glevel, rlevel, nmpi,
zlayer and vgrid.
The formula to calculate the number of regions and grids is as below:

    [# of regions]              = 10 * 4^(rlevel)
    [# of horiz. grids/PE]      = ( 2^(glevel-rlevel) +2 )^2 * ( [# of regions] / nmpi )
    [# of horiz. grids(total)]  = [# of horiz. grid /PE ] * nmpi
    [total # of grids]          = [# of horiz. grid(total)] * ( zlayer + 2 )

The following table shows some combinations of glevel, zlayer, rlevel, nmpi,
and their resulting grid and region configuration.

    |                               | # of  |# of horiz.|# of horiz. | total # of|
    |glevel |zlayer |rlevel | nmpi  |regions| grids/PE  |grids(total)|   grids   |
    |:-----:|:-----:|:-----:|:-----:|:-----:|:---------:|-----------:|----------:|
    | 5     | 80    | 0     | 10    |  10   | 1,156     |11,560      |947,920    |
    | 5     | 40    | 0     | 10    |  10   | 1,156     |11,560      |485,520    |
    | 5     | 160   | 0     | 10    |  10   | 1,156     |11,560      |1,872,720  |
    | 5     | 80    | 1     | 40    |  40   | 324       |12,960      |1,062,720  |
    | 5     | 80    | 2     | 160   |  160  | 100       |16,000      |1,312,000  |
    | 5     | 80    | 0     | 2     |  10   | 5,780     |11,560      |947,920    |
    | 6     | 80    | 1     | 40    |  40   | 1,156     |46,240      |3,791,680  |
    | 7     | 80    | 2     | 160   |  160  | 1,156     |184,960     |15,166,720 |
    | 8     | 80    | 3     | 640   |  640  | 1,156     |739,840     |60,666,880 |
    | 9     | 80    | 4     | 2560  |  2560 | 1,156     |2,959,360   |242,667,520|

Each test job uses the boundary files and a vertical file, which should
be set according to the problem configuration.
The boundary files are chosen according to the values of glevel, rlevel, nmpi.
The name of the boundary file for each PE is decided as follows:
    "boundary_GL${glevel}RL${rlevel}.pe${PE number in 6 digits}"

These boundary files are located under the directory:
    "gl${glevel}rl${rlevel}pe${PEs}"  

An example of boundary dir/files for a small problem configuration
is shown below.

    | glevel | rlevel | nmpi   | boundary dir. | boundary files                |
    |:------:|:------:|:------:|:-------------:|:------------------------------|
    | 5      | 0      | 10     | gl05rl00pe10  | boundary_GL05RL00.pe00000[0-9]

The vertical file is chosen according to the value of zlayer.

    | zlayer | name of vertical file |
    |:------:|:----------------------|
    | 80     |vgrid80_24000-300m.dat |
    | 40     |vgrid40_24000-600m.dat |
    | 160    |vgrid160_24000-150m.dat|

For the numerical stability, DTL (=delta t[sec]) and DIFCF (=parameter for
numerical diffusion) should be changed when glevel is modified.
The following table is the values which we prefer.

    | glevel | DTL  | DIFCF    |
    |:------:|:----:|---------:|
    | 5      | 1200 |1.290E+16 |
    | 6      | 600  |1.612E+15 |
    | 7      | 300  |2.016E+14 |
    | 8      | 150  |2.520E+13 |
    | 9      | 75   |3.150E+12 |


The other configuration will require the corresponding data files
and test.conf files.


Brief explanation of NICAM and NICAM-DC
---------------------------------------

NICAM ( Nonhydrostatic ICosahedral Atmospheric Model ) has been continuously
developed for the high-resolution climate study by explicit cloud expression.
The first global simulation using NICAM with 3.5km of horisontal mesh was
performed in 2004.
The development of NICAM with full physics has been co-developed mainly by
Japan Agency for Marine-Earth Science and Technology (JAMSTEC),
Atmosphere and Ocean Research Institute (AORI) at The University of Tokyo,
and RIKEN Advanced Institute for Computational Science (AICS).
A reference paper for NICAM is Satoh et al. (2008). See also [NICAM.jp Website][link].

[link]:http://NICAM.jp

NICAM is composed of two major procedure blocks each having its own computational
characteristics.

#####1. Dynamics phase computation
This phase is basically a stencil type computation, and requires high Byte/Flop
ratio
(B/F ~= 5.0).
It requires frequent neighbor data communications.

#####2. Physics phase computation
This phase involves many sequential computations, and requires relatively low
B/F raio
(B/F ~= 2).
The horizontal grid space does not have dependency. It does not require data
communication.

NICAM-DC corresponds to the dynamics phase computation, and has been developed
as a separate standalone program out of NICAM.
The License term of nicam-dc-mini is provided in the BSD 2-Clause License.
Please refer to "LICENSE" file included in the nicam-dc-mini package.

Contact for inquiry regarding NICAM-DC should be made to:

_ RIKEN Advanced Institute for Computational Science, Computational Climate System Research Team _

_ email: <aics-climate@riken.jp> _



Target exa-scale model parameters
--------------------------------
Following is the expected model parameter for year 2018 - 2020 time span.
Remark that the evaluations are based on the Full-NICAM experiment,
not on the NICAM-DC.

   Long duration, ensemble case: GL09RL03z38
   Duration time: 20 years (10M steps) or 1 year x 20
   Total Memory: 0.7Tbyte
   Total I/O: 150TByte (output every 6 hour)

   High-resolution, deterministic case: GL14RL07z94
   Number of horizontal grids: 2.5G (440m)
   Number of vertical grids: 94
   Duration time: 1 month (2.5M steps)
   Total Memory: 900TByte
   Total I/O: 500Tbyte (output every 3 hour)

   Ultra-high-resolution case: GL16RL09z200
   Number of horizontal grids: 40G (110m)
   Number of vertical grids: 200
   Duration time: 2 days (1.5M steps)
   Total Memory: 30PByte
   Total I/O: 500TByte (output every 30 min)



