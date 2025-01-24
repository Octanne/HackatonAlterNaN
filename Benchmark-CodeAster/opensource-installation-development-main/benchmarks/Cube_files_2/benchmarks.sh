#!/bin/bash
REFINE=3 /opt/aster/install/mpi/bin/run_aster Cube_perf.py > bench_3_Grav3.txt
REFINE=4 /opt/aster/install/mpi/bin/run_aster Cube_perf.py > bench_4_Grav3.txt
REFINE=5 /opt/aster/install/mpi/bin/run_aster Cube_perf.py > bench_5_Grav3.txt
REFINE=6 /opt/aster/install/mpi/bin/run_aster Cube_perf.py > bench_6_Grav3.txt
REFINE=6 /opt/aster/install/mpi/bin/run_aster -n 2 Cube_perf.py > bench_6_2_Grav3.txt
REFINE=6 /opt/aster/install/mpi/bin/run_aster -n 4 Cube_perf.py > bench_6_4_Grav3.txt
REFINE=6 /opt/aster/install/mpi/bin/run_aster -n 8 Cube_perf.py > bench_6_8_Grav3.txt
REFINE=7 /opt/aster/install/mpi/bin/run_aster  Cube_perf.py > bench_7_Grav3.txt
REFINE=7 /opt/aster/install/mpi/bin/run_aster -n 2 Cube_perf.py > bench_7_2_Grav3.txt
REFINE=7 /opt/aster/install/mpi/bin/run_aster -n 4 Cube_perf.py > bench_7_4_Grav3.txt
REFINE=7 /opt/aster/install/mpi/bin/run_aster -n 8 Cube_perf.py > bench_7_8_Grav3.txt
REFINE=8 /opt/aster/install/mpi/bin/run_aster Cube_perf.py > bench_8_Grav3.txt

#
