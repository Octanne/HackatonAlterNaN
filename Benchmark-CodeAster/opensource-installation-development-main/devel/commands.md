# Writing and operating commands

---
**NOTE:**
The data structures in which code_aster will store the information are historically called *concepts*.

---

## The command catalogue 

The command catalogue does not change syntax, it is found in `code_aster/Cata/Commands`.

All commands are executed by a Python function (we will see this later).
This function is very often *generic*, inherited from the `ExecuteCommand` base class, and then calls the `op` Fortran routine indicated in the catalogue.
When the implementation of this function is specific, the `op` attribute is set to *None* in the catalogue.
For example:

```python
DEFI_MATERIAU=OPER(nom="DEFI_MATERIAU", op=None, ...)
```

## The keywords manipulating in Python space

We recall the overall structure of keywords for code_aster:

- The first level consists of a list of simple keywords and factors keywords;
- Simple keywords can be of variable length, and therefore list or tuple;
- For factor keywords, there is a second level that can only be made up of simple keywords;

To retrieve what was given under a keyword, as `keywords` is a dictionary :

```python
materialField = keywords["CHAM_MATER"]
```

This direct access to the dictionary assumes that the keyword exists and that it has a value (mandatory keyword for example), without which a Python exception will be launched. It is therefore often preferable to use the `get`method :

```python
caraElem = keywords.get("CARA_ELEM")
```

This method returns `None` if the keyword is not specified or does not exist.

Whether the keyword is a real, an integer, a vector or an aster concept, it doesn’t change anything to its access by the dictionary, it’s a difference from the `getvid`, `getvr8` equivalent routines of Fortran that require to know the type before. The `keywords` dictionary allows access to the type of quantity given behind the keyword by the usual type method of Python.

Here is an example in the `DEFI_MATERIAU` command, the first level being made up only of unique factor keywords (of unit length) and simple keywords of unit length (the `INFO` keyword for example), we will test it in the following way:

```python
for fkwName, fkw in keywords.items():
    if type(fkw) in (list, tuple):
        assert len(fkw) == 1
        fkw = fkw[0]
```

We loop on all the keywords of the command via the dictionary. Here we check that if the keyword is a *list* or a *tuple*, it have to be of length 1.

The types available behind the keywords are those of Python or Numpy: *float*, *int*, *float64*, *complex*, *str*, *numpy*.

And all the data structures typed in code_aster that you find in the *Objects* Python module
(`code_aster/Objects`), which we don't have to forget to import explicitly, for example :

```python
from ..Objects import (DataStructure, Formula, Function,Material,
                       MaterialProperty, Function2D, Table)
```

To manipulate keywords, you will find very useful methods in the *Utilities* module (`code_aster/Utilities`), for example the utility to transform a "iterable" Python type into a *list* Python type :

```python
from ..Utilities import force_list
fkw = force_list(keywords.get("EXCIT", []))
```

You also sometimes have common keywords between commands (type of solver for example):

```python
from .common_keywords import create_solver
solver = create_solver(keywords.get("SOLVEUR"))
```

We will note that the `common_keywords` module is imported at the level of `code_aster/Cata/Commands`.

When a keyword is a list of real or integers, we access its values using the `getValues` method.
For example:

```python
listInst = keywords.get("LIST_INST")
if listInst is not None:
    mechaSolv.setTimeStepManager(listInst.getValues())
```

If the keyword is a factor keyword, its content is a dictionary.
For example:

```python
for fkwName, fkw in keywords.items():
    if not isinstance(fkw, dict):
        continue
    for skwName, skw in fkw.items():
        if type(skw) in (float, int, numpy.float64):
            print('Pouet1')
        elif type(skw) is complex:
            print('Pouet2')
        elif type(skw) is str:
            print('Pouet3')
        elif type(skw) is Table:
            print('Pouet4')
```

The first loop iterates on the dictionary of all the keywords of the command, we test if the keyword is a factor by checking that it contains a dictionary :

```python
isinstance(fkw, dict)
```

So if it’s a dictionary, then it’s a factor keyword and we loop on instances of that factor keyword :

```python
for skwName, skw in fkw.items():
```

Depending on the type, we do a special treatment (here, we have **pouette**):

```python
if type(skw) in (float, int, numpy.float64):
    print('Pouet1')
elif type(skw) is complex:
    print('Pouet2')
elif type(skw) is str:
    print('Pouet3')
elif type(skw) is Table:
    print('Pouet4')
```

## The class of the command

The effective processing of the command is done in the Python class of the same name in the Python module `Commands` (in the directory {file}`code_aster/Commands`).

The command is a *class* that inherits from `ExecuteCommand` (it is stored in the directory {file}`code_aster/Cata/Commands`).
For example, for `MECA_STATIQUE`, we define the `MechanicalSolver` class that inherits from the `ExecuteCommand` file  {file}`code_aster/Cata/Commands/meca_statique.py`:

```python
class MechanicalSolver(ExecuteCommand)
```

### Main methods

The actual execution of the command is performed by the `run` class method.
For example:

```python
MECA_STATIQUE = MechanicalSolver.run
```

This is therefore the method that is executed when the user writes
`result = MECA_STATIQUE(...)`.

<!-- The blank line at the end of the Note block matters-->
---
**NOTE**:

This class method must not be overloaded by the classes derived from the `ExecuteCommand`, except for the command `DEBUT`.

---

The `ExecuteCommand.run` class method starts by creating an instance of the class (and therefore goes through the Python constructor `__init__` ):

```python
class ExecuteCommand(object):
    def run(cls, **kwargs):
        cmd = cls()
        return cmd.run_(**kwargs)
```

Then, it calls the `run_` method on the instance of the newly created command that will execute the following methods successively :

- `adapt_syntax` allows us to optionally transform a syntax between an old implementation and a new one. This method does nothing by default;

- `check_syntax` checks that the compliance of the command as given by the user with respect to the grammar described in the command catalogue;

- `create_result` will create the data structure object (concept) derived from the  `DataStructure` class (see related documentation). It is mandatory to fill in this method when the operator creates a new data structure (i.e. it has something to the left of its = sign), otherwise the `NotImplementedError` exception is launched;

- `exec_` is the main method of the class. By default, it calls the adapted Fortran operator, otherwise it is in this function that we will decode the instructions of the command;

- `post_exec_` allows us to perform operations after execution. It calls the `post_exec` method, that can be overloaded by the inheriting class from `ExecuteCommand`.
  This `post_exec` coating allows us to call a *hook* at the end of the command (see the `register_hook` method).

In practice, a  (no core) developer will be able to modify the following methods in the command inherited from `ExecuteCommand`:

- For Fortran commands:`adapt_syntax`, `create_result` and `post_exec`.
  The `create_result` method will be modified in a mandatory way  when the operator creates a data structure;
- For commands in Python, the `exec_` method will be written to execute the command itself since we are in the case where the `op` Fortran routine is not called directly.

#### Constructor

The constructor defines all the attributes of the instance.
`ExecuteCommand` child classes don’t have to overload it.
The command name is defined in the `command_name` class attribute and is mandatory.
The commands catalogue to use is automatically determined from this name.
It can also be defined by the `command_cata` class attribute.

The minimum definition of the class, for a command that does not build a data structure (nothing to the left of the = sign) and that directly calls the operator in Fortran is therefore the following :

```python
class class ImprResu(ExecuteCommand):
    command_name = "IMPR_RESU"
```

#### Definition of the output data structure: `create_result`

This method has the `keywords` dictionary of keywords as input. It is mandatory to fill in this method when the operator creates a data structure (i.e. it has something to the left of its = sign), otherwise the `NotImplementedError` exception is launched. Here is an example for the  `DEFI_MATERIAU` command (`MaterialDefinition` class):

```python
class MaterialDefinition(ExecuteCommand):
    command_name = "DEFI_MATERIAU"

    def create_result(self, keywords):
        if keywords.get("reuse"):
            assert keywords["reuse"] == keywords["MATER"]
            self._result = keywords["MATER"]
        else:
            self._result = Material()
```

The `create_result` method defines the type of data structure returned by the command.
We also see in the example above that we can manage the `reuse` case, that is considered as a keyword:

```python
if keywords.get("reuse"):
    assert keywords["reuse"] == keywords["MATER"]
```

The previous code does a check. If the `reuse` keyword is used, the object provided have to be the same as that of `MATER`, this is the translation of the catalogue condition:

```python
reentrant = 'f:MATER',
reuse     = SIMP(statut='c', typ=CO),
MATER     = SIMP(statut='f', typ=mater_sdaster),
```

It is therefore a check of consistency with the catalogue.
Then, we create the instance of the `self. _result` result, in `reuse` in our case, it is the concept given behind the `reuse` keyword :

```python
self._result = keywords["MATER"]
```

Otherwise we create a new instance of the class and therefore a new data structure:

```python
self._result = Material()
```

Of course, `Material` is a class defined elsewhere in the C++ and accessible in Python. It necessarily exists for all data structures.

#### The post-execution operations: `post_exec`

At the end of a command, it is possible to perform operations using the `post_exec` method. This function is called by its internal version `post_exec_` of the `ExecuteCommand` parent class , that is executed by `run`, here is its content:

```python
try:
    self.post_exec(keywords)
    if isinstance(self._result, DataStructure):
        self.add_dependencies(keywords)
    if self.hook:
        self.hook(keywords)
finally:
    self.print_result()
```

We see several operations in a row:

- Call of the `post_exec` function that does nothing by default;

- If the result of the command, `self. _result`, exists and it is a `DataStructure` (not a simple Python object *int* for example or *None*),  we call `add_dependencies` method;

- Possible call of a `hook` (advanced use to force the call of a function after each command, a priori for debugging);

- Print statistics about the command (product object, time, memory, CPU, etc.) using the `print_result` method.

If it's necessary in a command, we can overload `post_exec` (and not `post_exec_` to specify the result produced).

### The dependency management

Data structures have a dependency between them. For example, a `Model`  object depends on a `Mesh` object.

The life cycle object is managed by reference counting.
Thus, as long as there is a reference to an object, it is kept. When there is no more reference to this object, it is automatically destroyed.

Schematically, if we write:

```python
mesh = Mesh()
model = Model(mesh)
```

At this point, there is a reference to the *Model* via the `model` Python variable.
There are two references to the *Mesh* object: the `mesh` Python variable and the *Model* via its `_baseMesh` C++ internal attribute, that points to the *Mesh* object. 
Then:

```python
del mesh
```

We lost the `mesh` Python variable, so there is still a reference to the mesh via the attribute `_baseMesh`. We can therefore continue to use the mesh without risk that it is destroyed.
Next:

```python
del model
```

We lose the `model` Python variable. There is therefore no more reference to the model, so it is destroyed. In cascade, its internal attributes are purged, in particular  `_baseMesh`.
So we lose the last reference to the mesh that is then destroyed.

Unfortunately, all objects are not as well defined in C++ as *Mesh* and *Model*. Some objects are much more complicated or with more or less well defined dependencies in *Jeveux* objects.
For this reason, we can add dependencies between objects at the Python level.

---
**NOTE:**

The default operation of commands is therefore to assume that the object produced by a command depends on the objects provided as input.

---

---
**NOTE:**

There is no risk of adding a dependency that would already exist at the C++ level (for example, the case of the *Mesh* and the *Model* above). If it is added *in duplicate*, it will automatically be deleted *in duplicate* upon destruction.

---

It is the `add_dependencies`  method of the `ExecuteCommand` that by default adds dependencies in the product concept to input objects. This method is called by the `post_exec_` coating method seen in the previous paragraph.

This default implementation recursively calls `_add_deps_keywords` to browse all of the keywords of the command.
For each input  `value` object of the `DataStructure` type, a dependency is explicitly added by the  `addDependency` method :

```python
for value in toVisit:
    if isinstance(value, DataStructure):
        self._result.addDependency(value)
```

This implementation is a precaution. It adds too many dependencies in the general case and leads to keep objects that could be deleted.
As soon as this case is identified in a command, it is necessary to overload the `add_dependencies` method.

We will take the example of the `CALC_CHAMP`command. In fact, the `CALC_CHAMP` command produces a new result or enriches an old one.
Whatever happens (new result or enrichment of a previous one), we always give in input of the command a reference to the result (`RESULT` simple keyword) from which we want to calculate the fields. So let us consider the following chain of commands :

```python
calc1 = STAT_NON_LINE()
calc2 = CALC_CHAMP(RESULT=calc1, CONTRAINTE = ('SIEF_NOEU'))
```

There is no reason to introduce a dependency between `calc1` and `calc2`, which the default implementation of `add_dependencies` would do.

We therefore overload the `add_dependencies` method for the `CALC_CHAMP`command.
We have:

```python
class ComputeAdditionalField(ExecuteCommand):
    command_name = "CALC_CHAMP"

    def add_dependencies(self, keywords):
        super().add_dependencies(keywords)
        self.remove_dependencies(keywords, "RESULT")
        if "reuse" not in keywords:
            try:
                model = keywords["RESULT"].getModel()
                if model:
                    self._result.addDependency(model)
            except RuntimeError:
                pass
            try:
                fieldmat = keywords["RESULT"].getMaterialField()
                if fieldmat:
                    self._result.addDependency(fieldmat)
            except RuntimeError:
                pass
            try:
                elem = keywords["RESULT"].getElementaryCharacteristics()
                if elem:
                    self._result.addDependency(elem)
            except RuntimeError:
                pass
```

The first thing that is done is to apply the generic method by:

```python
super().add_dependencies(keywords)
```

`super().add_dependencies` indicates that we want it to apply the `add_dependencies` method of the parent class of the `ComputeAdditionalField` (i.e., `ExecuteCommand`). So we add all dependencies to the input objects.
Then we call the `remove_dependencies` method with the `RESULT` parameter:

```python
self.remove_dependencies(keywords, "RESULT")
```

This method removes the dependence of the data structure produced compared to the object provided to the `RESULT` keyword. This method has the good taste not to stop in error if the `RESULT` was not provided, to loop on the different objects if there are several of them.
This method can also be called with a couple simple keywork / factor keywork.

Then, it is necessary to reintroduce the dependence of `calc2` on the model, on the material and on the elementary characteristics used in `calc1` support.
We retrieve each parameter using the “Result” object methods and we add it to the dependency list by `addDependency`. For example for the model:

```python
try:
    model = keywords["RESULT"].getModel()
    if model:
        self._result.addDependency(model)
    except RuntimeError:
        pass
```

---
**NOTE:**

To remember : The default implementation of `add_dependencies` is conservative and may in some cases add unnecessary dependencies.
For each command, we have to ask ourselves the question of the dependencies of the object produced to the input data and limit the additions to a minimum by overloading `add_dependencies` in the class describing the command.

---

### The call to another command

As an example of a post-execution operation, we can do a process that we consider independent of the command as in `MECA_STATIQUE` for the calculation of the `SIEF_ELGA` and `STRX ELGA` options, that can call the `CALC_CHAMP` command :

```python
def post_exec(self, keywords):
    if self._result is not None:
        contrainte = []
        if keywords["MODELE"].existsMultiFiberBeam():
            contrainte.append("STRX_ELGA")
        if keywords.get("OPTION") == "SIEF_ELGA":
            contrainte.append("SIEF_ELGA")
        if contrainte:
            CALC_CHAMP(reuse=self._result,
                       RESULT=self._result,
                       CONTRAINTE=contrainte)
        else:
          self._result.update()
```

Let’s break down these operations. First, it should be recalled that the `_result` attribute was created and instantiated by the `create_result` operation. It is necessarily a Python object of a class inherited from the `DataStructure`. The operations are as follows :

- We first check that the command was executed without error and therefore that the data structure exists;
- From the `MODELE` keyword, we call the `existsMultiFiberBeam` method, that allows us to know if there are elements of multifibre beam type.
  If this is the case, we add the `“STRX_ELGA”` string to the `constraint` list;
- We check if the user has entered `OPTION='SIEF_ELGA` and, if this is the case, we add the `"SIEF_ELGA"` string to the `constraint` list;
- We call the `CALC_CHAMP` command  with these options contained in the `constraint` list.

### Manipulating the `RESULT` data structure

[//]: # (MC: This paragraph seems off topic to me.)
[//]: # (These C++ internal objects come like as a hair on the soup.)
[//]: # (We must speak in terms of Python object because we are in code_aster/Commands.)

The `RESULT` data structure is defined by the `Result` object that derives from the `DataStructure` parent class and the `ListOfTablesClass` class.
This object needs additional information, in particular a description of the fields that are stored there. To correctly inform these objects, we use the object of `FieldBuilder` type (which is **not** an object derived from `DataStructure`) in the sense that this data structure only exists in the C++ space (and Python) but not in the Fortran.

Similarly, the `FullResultClass` object inherited from the `ResultClass` needs the numbering.
We therefore need to inform this information in the `CALC_CHAMP` command because they are not Jeveux objects (supported by internal operations in Fortran) but objects belonging to the C++ and Python classes.

---
**NOTE:**

This case is more and more frequent. Compared to *native* data structures, i.e. data structures having an existence in the code’s Fortran space, there are objects (classes) that are richer in the C++ (and Python) space and that need more information.

---

We therefore find in the `post_exec` method of the `CALC_CHAMP` operator :

[//]: # (MC: code block too long, obsolete as soon as it is written.)

```python
def post_exec(self, keywords):
    if "reuse" not in keywords:
        modele = keywords.get("MODELE")
        if modele is None:
            try:
                modele = keywords["RESULT"].getModel()
            except:
                modele = None
        if modele is None:
          try:
              modele = keywords["RESULT"].getDOFNumbering().getModel()
          except:
              modele = None
        if modele is not None:
            self._result.appendModelOnAllRanks(modele)
        try:
            dofNume = keywords["RESULT"].getDOFNumbering()
        except:
            dofNume = None
        if dofNume is not None:
            self._result.setDOFNumbering(dofNume)
    else:
        try:
            modele = self._result.getModel()
        except:
            modele = None
        if modele is None:
            modele = keywords.get("MODELE")
        if modele is not None:
            self._result.appendModelOnAllRanks(modele)
    self._result.update()
```

In the case of a new result data structure (no `reuse`):

- We retrieve the `Model`. Either by the keyword, or by the  `getModel` method of the data structure provided by the `RESULT` keyword ,  or through the numbering (dynamic case).
  If the `Model` has been retrieved, we add it to all order numbers of the data structure produced with the `appendModelOnAllRanks` method ;

- We proceed in the same way for the numbering.

Of course, in `reuse` mode, it suffices to retrieve the  `Model` in the input data structure.

We have modified the content of the `Result` type object, so it is necessary to call the `update` method that allows us to update its content.
