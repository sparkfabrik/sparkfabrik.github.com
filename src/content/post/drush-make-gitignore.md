+++
date        = "2016-04-08T01:00:00-04:00"
title       = "Drush Make overwrites your custom .gitignore file"
description = "An investigation about an undesired behavior: bug or feature?"
tags        = [ "development", "drupal", "drush"  ]
topics      = [ "Drupal" ]
slug        = "drush-make-gitignore"
author      = "Marcello Testi"
+++

# Managing a customized .gitignore file across drush make builds

## The problem

**[Drush](https://github.com/drush-ops/drush) 8** overwrites the .gitignore file after a successful makefile execution.

This affects complex projects where multiple dependency sources are present, and where other reasons might require a significant override of the **.gitignore** file provided by Drupal, which ends up diffed, causing `git status` to produce an ugly output, until the committed .gitignore is restored.

## Origin of the problem

In recent upgrades, the `--overwrite` option has been added to Drush in order to force the overwrite of existing folders (the command docs don't  mention files, althought some file reference is present in the code comments), while the default behavior is to *merge*, which means keeping existing folder content. This option has only an impact on **directories** inside the project's root and doesn't affect the files in the root.

## How the problem was investigated

 * I created a couple of docker containers based on [SparkFabrik base PHP image](https://hub.docker.com/r/sparkfabrik/docker-php-base-image/) well suitable for PHP/Drupal development.
 * In both containers, I replaced the default Drush version (8.0.5 installed with phar) so that I could debug and alter the code on the fly
 * In a container I installed version 6.7.0 (downloading the [release tarball](https://github.com/drush-ops/drush/releases/tag/6.7.0)) in the other I installed the "source" version of Drush 8.0.5 ([via composer](http://docs.drush.org/en/master/install-alternative/))
 * I created a small repository containing a .gitignore slightly different than Drupal's one, and a makefile with some dependencies
 * Then I executed `drush make` in both containers, with the `--debug` option that enhance output

## Execution flow

 * During makefile processing, files are downloaded in a temp directory and only at the end they are copied to the final destination by the function [`make_move_build`](https://github.com/drush-ops/drush/blob/8.0.5/commands/make/make.drush.inc#L739). The process is basically a recursive copy of the elements found in the root of the downloaded codebase.
 * `make_move_build` is also responsible for reading the `--overwrite` option and pass a consequent value to the function in charge of copying both files and directories: [`drush_copy_dir`](https://github.com/drush-ops/drush/blob/8.0.5/includes/filesystem.inc#L215).
 * Before calling `drush_copy_dir`, `make_move_build` loops through root-level items and treats directories differently (see https://github.com/drush-ops/drush/commit/d10826132d72f8dabc10a396efe43319d4a5b316).
 * In `drush_copy_dir` the value passed when `--overwrite` is set is only used to create a log entry (https://github.com/drush-ops/drush/blob/6.7.0/includes/filesystem.inc#L224), but not in order to avoid overwriting files.

## Workaround and solutions

As a workaround, we set the build system (we're currently using [Phing](https://www.phing.info/)) to execute a `git checkout` of the committed version of .gitignore.

The *real* solution might consist in applying the `--override` option (or lack of) also for root-level files, but I doubt this was intended by drush contributors, until now. In the following links, you can read a handful of relevant issues, for reference.

## Links

This was the issue that originated the change from the previous behavior: https://github.com/drush-ops/drush/pull/1450 (commit https://github.com/drush-ops/drush/pull/1450/commits/d10826132d72f8dabc10a396efe43319d4a5b316)

Other issues discussing the same subject:

* https://github.com/drush-ops/drush/issues/1468 "drush make does not overwrite root core files"
* https://github.com/NuCivic/dkan/issues/824 "Move dkan modules downloaded via drush make to their own folder"
* https://github.com/drush-ops/drush/issues/1269 "drush make `--overwrite` should respect `--projects=`?"
