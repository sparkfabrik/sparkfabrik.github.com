+++
date        = "2016-11-29T08:51:09+02:00"
title       = "Trapped by an amend, saved by a reflog"
tags        = ['git', 'reflog', 'amend']
topics      = ['git']
description = "Personal experience on getting in trouble with a common git command and finding my way out."
slug        = 'trapped-by-amend-saved-by-reflog'
author      = "Marcello"
+++
[SparkFabrik]: http://www.sparkfabrik.com/  "SparkFabrik"

We use Git on a daily basis, and most of the time we always enter the same commands.
It can happen to found ourselves trapped by one of them, sometimes because we forgot a side-effect, other times because we confused the right option.
No need to worry though, since Git is equally able to put you in trouble and save your day with the same ease. So, let me tell you how I was hit by an `--amend` during a commit and how I easily got out.

<!--more-->

Sometimes during the day, especially in the time right before lunch or leaving work, it's possible to forget one the most important rules of the savvy developer: in the console, you can be quick with all the keys, but think twice before pressing "enter".

Sure, I managed to break that very rule some days ago. Luckily that was a chance to remind me how much powerful Git is and how sometimes the solutions to an apparently bad situation can be just a few commands away.

## The amend secret

As many of you probably know, the `git commit --amend` command can be used to edit the message of the last commit in the history. This is one of the most common uses because - as developers - we are prone to typos and bad phrasing.
But the `--amend` option can also be used to include *new code* in the last commit.

For example:
Let's say you've just created a commit but you've also forgot to add a block comment to that very method you've written, and you don't want to have another commit in the history, for various reasons. You have many choices at this point, including creating a new commit with the new lines and squash it with the previous one using the `git rebase` command.

But you can also do this:

``` bash
# Add new line and prepare them for the commit.
git add -p
# Amend the previous commit and add to it the staged modifications.
git commit --amend
```

A this point, you are asked to edit the previous commit message and the staged edits will be included in it. Useful, isnt'it?

## The side effect

This little trick can be very handy in many situations, but it can also be a very sharp double-edged sword because, as you probably have guessed, you can use the amend on *any* commit including, for example, a *merge commit*.

So, here's a possible sequence of commands that could generate a bad situation.

``` bash
# You add some modifications.
git add -p
# Then create a new commit
git commit -m 'Added new public method'
# Then merge the last develop in your working branch
git fetch --all
git merge origin/develop
```

So far the history of your branch could be something like:

``` bash
~$ git log --oneline

b1748d6 Merge remote-tracking branch 'origin/develop' into feature/my_branch
a69fa15 Added new public method
```

Now you accidendally amend the next modifications instead of creating a new commit.

``` bash
# Write a block comment for your new method and stage the new modifcations.
git add -p
# But instead of creating a new commit, you use the --amend option.
git commit --amend
```

At this point, the history will be almost the same, but the hash of the *merge commit* will be different and that commmit will include your new block comment too.

``` bash
~$ git log --oneline

f5a5377 Merge remote-tracking branch 'origin/develop' into feature/my_branch
a69fa15 Added new public method
```

That's bad.

## The git reflog solution

Since you want to restore the situation before the amend, you can decide to use the `git reflog` in combination with a `git reset`.

The `git reflog` command will prompt the history of the last commands you've entered.
The output will look something like this.

``` bash
~$ git reflog

f5a5377 HEAD@{0}: commit (amend): Merge remote-tracking branch 'origin/develop' into feature/my_branch
b1748d6 HEAD@{1}: merge origin/develop: Merge made by the 'recursive' strategy.
a69fa15 HEAD@{2}: Added new public method
```

As you can see you have a separate line for each commit action made, and it is pretty easy to solve the problem. Having the **HEAD@{1}** hash now you can go back there, removing *de facto* the last command from the history.

``` bash
# We go back in the history up to the merge commit.
git reset --soft b1748d6
# At this point we'll have all the edits that we wrongly added to the merge commit already staged and ready to be added to a new commit.
git commit -m 'Added new block comment'
```

## Conclusion

Here it is. One simple problem and one simple solution.
What I learned when I've found myself in a situation like this one is that your understanding of Git can really make the difference sometimes. Knowing the commands main purpose is as important as having a basic undestanding of their possibile secondary uses and side effects, but it is also crucial to remember that Git itself provides the tools to investigate and solve critical situations.
