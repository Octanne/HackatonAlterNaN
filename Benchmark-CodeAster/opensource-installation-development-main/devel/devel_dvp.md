# Use Mercurial to organize the developments

## Some recommendations and applicable rules

- In the published tree, intermediate commits where we correct a typing error have no interest. We must be merged with one another. Similarly, if we go back on a modification, it don't have to appear in the history.

  On the other hand, **it is recommended to keep the different stages of development**.

- All revisions must be compilable (we have to be able to do `waf configure` and `waf install` on it).

  It is not imposed that test cases pass with all revisions.
  This is generally not the case when we cut a development into several stages (tests are often finalized).

- All revisions to the same form must be contiguous.

- We want to publish a linear, easy to read history and therefore we ask the developers to submit an equally linear history.
  Do not use `hg merge` but rather `hg rebase` to *move* your developments to the new head. See [Resuming development after an update](/devel/devel_dvp#resuming-development-after-an-update).

- Commit messages must be written in English (because revisions are published on Internet). The message don't have to repeat the title of the form but what was done in the given revision to contribute to the resolution of the form.

  See [FAQ](/usage/faq#frequently-asked-questions)

- The revisions submitted for integration must correspond to REX forms validated in EDA.

---
**Reminder** : This is the last message of the form that constitutes the text of the history. We must mention:

- the origin of the problem (how it occurred) in the event of an anomaly or the need expressed in the event of a evolution request,
- the description of what was done to respond to it,
- how the modifications were validated.

---

We provide some leads below to arrive at this.

## Reference revision

When we start a new development, it is important to start from the source files of the official version (and not from another development in progress for example).

To do this, the `install_env` script adds two interesting *revsets*:

- `reference` or `refe`: this is the last revision of the reference repository in the current branch, so this is the last official revision from which we must start.
- `new`: this is the set of parent revisions of the unknown current revision of the reference repository (the revisions composing the current development not yet integrated).

To consult the latest official revision, we do :

```sh
hg log --rev reference
```

We do so before starting a new development, and each time we want to go back to the latest revision of the reference repository:

```sh
hg pull
hg update reference
# ou
hg up refe
```

---
**ATTENTION:**

`hg update` keeps current modifications to the working directory. Do `hg update --clean` to ignore and lose current modifications (cf. `hg update --help`).

---

---
**ATTENTION:**

To merge developments associated with several forms, or to update a development on the latest official revisions, we could use `hg merge`.
However, in order to publish a linear, easy to understand history, we ask to use `hg rebase` to "move" your revisions on the new head.

---

## Realization of one or more developments

<!--
Please keep these instructions to reproduce the example history:

hg up
echo '#reference' >> wscript
hg ci -m '[#19999] this is the last integrated revision!'
refe=`hg parent --template '{node|short}'`
hg log -r $refe
echo '#issue20526' >> wscript
hg ci -m '[#20526] commit to solve a first issue'
iss1=`hg parent --template '{node|short}'`
hg up $refe
echo '#issue20145_step1' >> wscript
hg ci -m '[#20145] first step for a second issue'
iss2=`hg parent --template '{node|short}'`
echo '#issue20145_step2' >> wscript
hg ci -m '[#20145] another step for a second issue'
hg log -G --template="{rev}:{node|short} {branch}: {desc|firstline}\n" -l 4
-->

1. See previous paragraph, we start from the last integrated revision

   ```sh
   $ hg update refe
   $ hg parent
   changeset:   1464:0ab3abbb22dd
   user:        Mathieu Courtois <mathieu.courtois@edf.fr>
   date:        Tue Jul 30 23:30:44 2013 +0200
   summary:     [#19999] this is the last integrated revision!
   ```

2. Modification source files to solve a first form, then commit

   ```sh
   hg ci -m '[#20526] commit to solve a first issue'
   ```

3. Before starting a new development, we go back to the reference revision, then modify the files and perform in two commits

   ```sh
   hg update refe
   ...
   hg ci -m '[#20145] first step for a second issue'
   ...
   hg ci -m '[#20145] another step for a second issue'
   ```

We obtain a tree of this type [^hglog], composed of the two anonymous branches corresponding to the two developments:

```none
@  1467:10b01de78dcb default: [#20145] another step for a second issue
|
o  1466:0e76dc887c63 default: [#20145] first step for a second issue
|
| o  1465:1b39f6c1f683 default: [#20526] commit to solve a first issue
|/
o  1464:0ab3abbb22dd default: [#19999] this is the last integrated revision!
|
```

We have no interest in merging developments before requesting integration.

## Resuming development after an update

<!--
Please keep these instructions to reproduce the example history:

hg up $refe
echo '#newrefe' >> wscript
echo '#issue20526' >> wscript
hg ci -m '[#18888] a new official head'
refe=`hg parent --template '{node|short}'`
hg log -G --template="{rev}:{node|short} {branch}: {desc|firstline}\n" -l 5
hg rebase -s $iss1 -d $refe
hg up tip
iss1=`hg parent --template '{node|short}'`
hg rebase -s $iss2 -d $refe
hg up tip
iss2=`hg parent --template '{node|short}'`
hg log -G --template="{rev}:{node|short} {branch}: {desc|firstline}\n" -l 5
-->

By repeating the above situation, we assume that other revisions have been incorporated into the reference repository.

1. So we retrieve the new revisions from the reference repository and we go to `refe`:

   ```sh
   hg pull
   hg up refe
   ```

   The tree became :

   ```none
   @  1468:12e1efd54f41 default: [#18888] a new official head
   |
   | o  1467:10b01de78dcb default: [#20145] another step for a second issue
   | |
   | o  1466:0e76dc887c63 default: [#20145] first step for a second issue
   |/
   | o  1465:1b39f6c1f683 default: [#20526] commit to solve a first issue
   |/
   o  1464:0ab3abbb22dd default: [#19999] this is the last integrated revision!
   |
   ```

2. We use `rebase` to *move* revisions to the new head.
   We move the first revision of each branch, the child revisions follow  (`hg up tip` updates the working directory on the newly created revision).

   ```sh
   $ hg rebase -s 1b39f6c1f683 -d refe
   saved backup bundle to ***/.hg/strip-backup/1b39f6c1f683-backup.hg
   $ hg up tip
   $ hg rebase -s 0e76dc887c63 -d refe
   saved backup bundle to ***/.hg/strip-backup/0e76dc887c63-backup.hg
   ```

   This leads to:

   ```none
   @  1468:db87dd7d8c4e default: [#20145] another step for a second issue
   |
   o  1467:54bbe7c14e0c default: [#20145] first step for a second issue
   |
   | o  1466:adb30e012987 default: [#20526] commit to solve a first issue
   |/
   o  1465:12e1efd54f41 default: [#18888] a new official head
   |
   o  1464:0ab3abbb22dd default: [#19999] this is the last integrated revision!
   |
   ```

   We can notice that these are new revisions, they were not *moved*, but rewritten.

## Assembling the forms to make a submit

<!--
Please keep these instructions to reproduce the example history:
hg rebase -s $iss2 -d $iss1
hg up tip
hg log -G --template="{rev}:{node|short} {branch}: {desc|firstline}\n" -l 5
iss2=`hg log -r tip^ --template '{node|short}'`
-->

In order to propose developments for integration into the reference repository, we will assemble the two branches.

We could do a `hg merge`, but since we want to publish a linear history for readability, we will rewrite the history.

The order can be chosen according to the modifications related to each development.
Here, we choose to put the second form after the first.

```sh
$ hg rebase -s 54bbe7c14e0c -d adb30e012987
saved backup bundle to ***/.hg/strip-backup/54bbe7c14e0c-backup.hg
```

The tree becomes :

```none
@  1468:23655e7f2366 default: [#20145] another step for a second issue
|
o  1467:9d300e6aa2d6 default: [#20145] first step for a second issue
|
o  1466:adb30e012987 default: [#20526] commit to solve a first issue
|
o  1465:12e1efd54f41 default: [#18888] a new official head
|
o  1464:0ab3abbb22dd default: [#19999] this is the last integrated revision!
|
```

## Return a posteriori to a form

<!--
Please keep these instructions to reproduce the example history:
hg rebase -s $iss2 -d $iss1
hg up tip
hg log -G --template="{rev}:{node|short} {branch}: {desc|firstline}\n" -l 5
iss2=`hg log -r tip^ --template '{node|short}'`
hg up $iss1
echo #another >> wscript
hg ci -m '[#20526] remove some warnings'
iss1=`hg parent --template '{node|short}'`
hg log -G --template="{rev}:{node|short} {branch}: {desc|firstline}\n" -l 6
hg rebase -s $iss2 -d $iss1
hg up tip
hg log -G --template="{rev}:{node|short} {branch}: {desc|firstline}\n" -l 6
-->

It may be necessary to come back on a development to correct or complete it when we thought it was finished.
Let’s take the case where we want to correct the #20526 form.

1. We replace the revision corresponding to this form

   ```sh
   hg up adb30e012987
   ```

2. We make the correction

   ```sh
   ... edit ...
   hg ci -m '[#20526] remove some warnings'
   ```

3. We find ourselves in the previous situation:

   ```none
   @  1469:a7838e7acd0a default: [#20526] remove some warnings
   |
   | o  1468:23655e7f2366 default: [#20145] another step for a second issue
   | |
   | o  1467:9d300e6aa2d6 default: [#20145] first step for a second issue
   |/
   o  1466:adb30e012987 default: [#20526] commit to solve a first issue
   |
   o  1465:12e1efd54f41 default: [#18888] a new official head
   |
   o  1464:0ab3abbb22dd default: [#19999] this is the last integrated revision!
   |
   ```

4. We linearise

   ```sh
   $ hg rebase -s 9d300e6aa2d6 -d a7838e7acd0a
   saved backup bundle to ***/src/.hg/strip-backup/9d300e6aa2d6-backup.hg
   ```

   ```none
   @  1469:0ab83e45a2e3 default: [#20145] another step for a second issue
   |
   o  1468:981cd9966d57 default: [#20145] first step for a second issue
   |
   o  1467:a7838e7acd0a default: [#20526] remove some warnings
   |
   o  1466:adb30e012987 default: [#20526] commit to solve a first issue
   |
   o  1465:12e1efd54f41 default: [#18888] a new official head
   |
   o  1464:0ab3abbb22dd default: [#19999] this is the last integrated revision!
   |
   ```

## Compact the history

<!--
Please keep these instructions to reproduce the example history:

iss1=`hg log -r 'tip^^^' --template '{node|short}'`
HGEDITOR=gedit hg histedit $iss1
hg log -G --template="{rev}:{node|short} {branch}: {desc|firstline}\n" -l 4
-->

During the development phase, we make many commits : as soon as a step is completed, before attempting another method, etc.

In the published tree, intermediate commits where we correct a typing error have no interest.

---
**NOTE:**

On the other hand, if the development is consequent, there can for example be very distinct steps (for example: "programming redesign", then "adding a new algorithm"). In this case, **it's necessary**  keep the commits separately because they each have a clear meaning. The only "limitation" to keep intermediate commits is that we must be able to compile the code at each published revision.

---

We assume in our example that each of the two forms can be summed up as a single revision, we use `hg histedit` to compact (`fold`) the history.

We request the edition of the history since adb30e012987 revision

<!--
Please keep these instructions to reproduce the example history:

hg histedit adb30e012987
-->

The editor opens with this content:

```none
pick adb30e012987 1466 [#20526] commit to solve a first issue
pick a7838e7acd0a 1467 [#20526] remove some warnings
pick 981cd9966d57 1468 [#20145] first step for a second issue
pick 0ab83e45a2e3 1469 [#20145] another step for a second issue

# Edit history between adb30e012987 and 0ab83e45a2e3
#
# Commands:
#  p, pick = use commit
#  e, edit = use commit, but stop for amending
#  f, fold = use commit, but fold into previous commit (combines N and N-1)
#  d, drop = remove commit from history
#  m, mess = edit message without changing commit content
#
```

We modify it to merge the first revision of each form with the following, that is:

```none
pick adb30e012987 1466 [#20526] commit to solve a first issue
fold a7838e7acd0a 1467 [#20526] remove some warnings
pick 981cd9966d57 1468 [#20145] first step for a second issue
fold 0ab83e45a2e3 1469 [#20145] another step for a second issue

# Edit history between adb30e012987 and 0ab83e45a2e3
#
# Commands:
#  p, pick = use commit
#  e, edit = use commit, but stop for amending
#  f, fold = use commit, but fold into previous commit (combines N and N-1)
#  d, drop = remove commit from history
#  m, mess = edit message without changing commit content
#
```

We are asked to produce a message from the two merged messages.

For example, we obtain:

```none
@  1467:0b5f9537fc51 default: [#20145] solve a second issue
|
o  1466:fc43889a3463 default: [#20526] commit to solve a first issue, remove some warnings
|
o  1465:12e1efd54f41 default: [#18888] a new official head
|
o  1464:0ab3abbb22dd default: [#19999] this is the last integrated revision!
|
```

[^hglog]: The condensed tree is obtained with:

    `hg log -G --template="{rev}:{node|short} {branch}: {desc|firstline}\n"`
