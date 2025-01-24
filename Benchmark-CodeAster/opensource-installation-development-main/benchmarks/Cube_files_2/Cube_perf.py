#!/usr/bin/python
# coding=utf-8

import os
from statistics import mean
from datetime import datetime
from resource import RUSAGE_SELF, getrusage

from code_aster.Commands import *
from code_aster import CA
from code_aster.Utilities import petscInitialize

CA.init()

params = {}
params["refinements"] = int(os.environ.get("REFINE", 1))
params["parallel"] = os.environ.get("USE_LEGACY", "HPC")
params["solver"] = os.environ.get("SOLVER", "PETSC")

# General parameters
comm = CA.MPI.ASTER_COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

nbHexa = 8 ** params["refinements"]


def memory_peak(mess=None):
    """Return memory peak in MB"""
    return int(getrusage(RUSAGE_SELF).ru_maxrss / 1024)


class ChronoCtxMgGen:
    stats = {}

    def __init__(self, what):
        self._what = what

    def __enter__(self):
        self.start = datetime.now()

    def __exit__(self, exctype, exc, tb):
        self.stop = datetime.now()
        delta = self.stop - self.start
        mem = memory_peak(self._what)
        self.stats[self._what] = [delta.total_seconds(), mem]


class ChronoCtxMg(ChronoCtxMgGen):
    pass
    # def __init__(self, what):
    #     ChronoCtxMgGen.__init__(self, what)


def write_stats(nume_ddl):
    if rank == 0:
        print("TITLE: TEST PERF CUBE")
        print()
        print("NB PROC")
        print(size)
        print()
        print(
            "COMMAND, TIME MIN (s), TIME MAX (s), TIME MEAN (s), MEM MIN (Mo), MEM MAX (Mo), MEM MEAN (Mo)"
        )

    for key, values in stats.items():
        time = comm.gather(values[0], root=0)
        mem = comm.gather(values[1], root=0)
        if rank == 0:
            print(
                key
                + ", "
                + str(min(time))
                + ", "
                + str(max(time))
                + ", "
                + str(mean(time))
                + ", "
                + str(min(mem))
                + ", "
                + str(max(mem))
                + ", "
                + str(mean(mem))
            )

    mesh = nume_ddl.getMesh()
    nodes = len(mesh.getInnerNodes())
    nodes = comm.allreduce(nodes, CA.MPI.SUM)

    if rank == 0:
        print()
        print("NB CELLS, NB NODES, NB DOFS")
        print(str(nbHexa) + ", " + str(nodes) + ", " + str(nume_ddl.getNumberOfDofs()))


def print_markdown_table(data, refine, nbcells, nbnodes, nbdofs):
    """Print a table of the mean time as a Markdown table."""

    def show(*args, **kwargs):
        if rank == 0:
            print(*args, **kwargs)

    fmti = "| {0:<16s} | {1:11,d} |"
    fmtt = "| {0:<16s} | {1:11.2f} |"
    separ = "| :--------------- | ----------: |"
    show(fmti.format("Refinement", refine))
    show(separ)
    show(fmti.format("Number of cells", nbcells).replace(",", " "))
    show(fmti.format("Number of nodes", nbnodes).replace(",", " "))
    show(fmti.format("Number of DOFs", nbdofs).replace(",", " "))
    show(fmti.format("Number of procs", size).replace(",", " "))
    show(fmti.format("Nb of DOFs/proc", nbdofs // size).replace(",", " "))
    for key, values in data.items():
        times = comm.gather(values[0], root=0)
        # mem = comm.gather(values[1], root=0)
        if rank == 0:
            show(fmtt.format(key, mean(times)))


# petscInitialize('-ksp_monitor_true_residual -stats' )
petscInitialize("-ksp_monitor_true_residual -log_view")

with ChronoCtxMg("Total"):
    with ChronoCtxMg("Build mesh"):
        if params["parallel"] == "HPC":
            mesh = CA.ParallelMesh.buildCube(refine=params["refinements"])
        else:
            mesh = CA.Mesh.buildCube(refine=params["refinements"])

    with ChronoCtxMg("Model"):
        model = AFFE_MODELE(
            MAILLAGE=mesh,
            AFFE=_F(
                TOUT="OUI",
                PHENOMENE="MECANIQUE",
                MODELISATION="3D",
            ),
        )

    with ChronoCtxMg("Material"):
        steel = DEFI_MATERIAU(
            ELAS=_F(
                E=200000.0,
                NU=0.3,
            ),
            ECRO_LINE=_F(
                D_SIGM_EPSI=2000.0,
                SY=200.0,
            ),
        )

        mater = AFFE_MATERIAU(
            MAILLAGE=mesh,
            AFFE=_F(
                TOUT="OUI",
                MATER=steel,
            ),
        )

    with ChronoCtxMg("Boundary conditions"):
        block = AFFE_CHAR_CINE(
            MODELE=model,
            MECA_IMPO=(
                _F(
                    GROUP_MA="LEFT",
                    DX=0,
                    DY=0.0,
                    DZ=0.0,
                ),
            ),
        )

        imposed_displ = AFFE_CHAR_CINE(
            MODELE=model,
            MECA_IMPO=(
                _F(
                    GROUP_MA="RIGHT",
                    DY=0.001,
                    DZ=0.001,
                ),
            ),
        )

    with ChronoCtxMg("Create matrix"):
        stiff_elem = CALC_MATR_ELEM(
            MODELE=model,
            OPTION="RIGI_MECA",
            CHAM_MATER=mater,
        )

    with ChronoCtxMg("Numbering"):
        dofNum = NUME_DDL(
            MATR_RIGI=stiff_elem,
        )

    with ChronoCtxMg("Assembly"):
        stiffness = ASSE_MATRICE(
            MATR_ELEM=stiff_elem,
            NUME_DDL=dofNum,
            CHAR_CINE=(block, imposed_displ),
        )

    with ChronoCtxMg("Build RHS"):
        rhs = CREA_CHAMP(
            TYPE_CHAM="NOEU_DEPL_R",
            OPERATION="AFFE",
            MAILLAGE=mesh,
            AFFE=_F(
                TOUT="OUI",
                NOM_CMP=(
                    "DX",
                    "DY",
                    "DZ",
                ),
                VALE=(
                    0.0,
                    0.0,
                    0.0,
                ),
            ),
        )

        load_vector = CALC_CHAR_CINE(NUME_DDL=dofNum, CHAR_CINE=(block, imposed_displ))

    if params["solver"] == "PETSC":
        solver = CA.PetscSolver(RENUM="SANS", PRE_COND="GAMG")
    elif params["solver"] == "MUMPS":
        solver = CA.MumpsSolver(
            MATR_DISTRIBUEE="OUI",
            RENUM="PARMETIS",
            ACCELERATION="FR+",
            POSTTRAITEMENTS="MINI",
        )

    with ChronoCtxMg("Factorize"):
        solver.factorize(stiffness)

    with ChronoCtxMg("Solve"):
        resu = solver.solve(rhs, load_vector)

# write_stats(dofNum)
nbNodes = len(mesh.getInnerNodes())
if params["parallel"] == "HPC":
    nbNodes = comm.allreduce(nbNodes, CA.MPI.SUM)
nbDOFs = dofNum.getNumberOfDOFs()
print_markdown_table(ChronoCtxMg.stats, params["refinements"], nbHexa, nbNodes, nbDOFs)

CA.close()
