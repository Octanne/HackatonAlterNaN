# Getting started with code_aster architecture

Summary

[[_TOC_]]

## Sources tree

| Path                       | Content                                           |
|:---------------------------|:--------------------------------------------------|
| `astest`                   | definition of testcases                           |
| `bibc`                     | C source files                                    |
| `bibcxx`                   | C++ source files                                  |
| `bibcxx/PythonBindings`    | definition of Python bindings to DataStructures   |
| `bibfor`                   | Fortran source files                              |
| `bibfor/include/asterfort` | interfaces of Fortran subroutines                 |
| `catalo`                   | elements description (a.k.a. _catalogs_)          |
| `code_aster`               | Python source files                               |
| `code_aster/Cata`          | definition of Commands keywords                   |
| `code_aster/Objects`       | import `libaster` objects and pure Python objects |
| `code_aster/ObjectsExt`    | Python extensions to DataStructures               |
| `doc`                      | source files of the embedded documentation        |

## From the Python API to Fortran

### Python binding

Example: `Function` object

```python
import numpy as np

code_aster.init()

fsin = code_aster.Function()

n = 10
valx = np.arange(n) * 2.0 * pi / n
valy = np.sin(valx)
fsin.setValues(valx, valy)

print(fsin.size())
print(fsin.getValues())
help(fsin)

print(fsin.getValuesAsArray())

code_aster.close()
```

- The `Function` Python API is defined in `bibcxx/PythonBindings/FunctionInterface.cxx`.

  ```c++
        .def( "setValues", &Function::setValues )
  ```

  This adds a Python method `"setvalues"` to the `Function` object that points
  to the C++ `Function::setValues` member.

- `Function::setValues` is defined in `bibcxx/Functions/Function{.h,.cxx}`.
  It is a _pure_ C++ function that assigns the input values into the `_value` vector.

- A _DataStructure_ object may be extended with pure Python methods.
  See `code_aster/ObjectExt/function_ext.py`, method `getValuesAsArray`.

**To go further:**

- `Function.h` defines the object content: members `_value` as `JeveuxVectorReal`
  (named `.VALE`), `_property` as `JeveuxVectorChar24` (named `.PROL`).

- All _DataStructures_ objects are imported (from `libaster`) into `code_aste.Objects`
  and into `code_aster` for convenience: `code_aster.Mesh` and `code_aster.Objects.Mesh`
  the same object.

  In source files, prefer import from `code_aster.Objects` instead of `code_aster`
  to avoid circular imports and dependencies.

Ref.: [Table of DataStructures](https://codeaster.readthedocs.io/en/latest/devguide/code_aster/Objects/index_DataStructure.html)

### Calling fortran subroutine from C++

Example: `Model` object

```c++
int Model::getGeometricDimension();
```

It calls `dismoi` using the macro `CALL_DISMOI` (that uses C-strings) or
`CALLO_DISMOI` (that uses C++ `std::string`), defined in `aster_fort_utils.h`.
These macros call the fortran subroutine by automatically adding `_` or by using
uppercase names, and by switching string arguments and their length according to
the compilation platform.

## Dive into a Command

```python
mat_as = ASSE_MATRICE(MATR_ELEM=mat_elem, NUME_DDL=num)
```

### Command description, a.k.a. catalog

The command description defines the function that is called + keywords and the result type.

- [Presentation](https://code-aster.org/UPLOAD/DOC/Formations/05-command_catalog1.pdf)

### Detailed execution of a Command

The execution of a Command is managed by the `ExecuteCommand` object.

```python
class ModelAssignment(ExecuteCommand):
    """Command that creates the :class:`~code_aster.Objects.Model` by assigning
    finite elements on a :class:`~code_aster.Objects.Mesh`."""

    command_name = "AFFE_MODELE"
    ...

AFFE_MODELE = ModelAssignment.run
```

It defines the Command name, the syntax description (catalog) to be used
and eventually specializes some stages.

See [ExecuteCommand object documentation](https://codeaster.readthedocs.io/en/latest/devguide/code_aster/Supervis.html#code_aster.Supervis.ExecuteCommand.ExecuteCommand
).

The classmethod `run` is a _factory_ that creates an instance at each command call.

The `exec_` method direcly calls the "`ops`" function for _macro-commands_.

## Exercise: adding a method to an object

Objective: Multiply a function by a scalar
(optionally: Overload of the multiply operator).

```python
fsin = Function()
...
reference_value = fsin(1.)

fsin.mult_scal(2.)
# or optionally:
fsin *= 2.

assert fsin(1.) == 2. * reference_value
```

This simple example can be resolved:

- in Python,
- in C++,
- in Fortran.

## References

- GitLab repositories: <https://gitlab.com/codeaster>

- The embedded documentation (built with `./waf doc` and published to
  `../install/mpi/share/doc/html/index.html`).

  On internet: <https://codeaster.readthedocs.io>

- Training materials on www.code-aster.org, section Formations:
  <https://code-aster.org/spip.php?article861>
  (some documents are outdated).
