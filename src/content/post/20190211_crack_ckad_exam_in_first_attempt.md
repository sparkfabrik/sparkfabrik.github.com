+++
date        = "2019-02-11T08:51:09+02:00"
title       = "Crack the CKAD exam in first attempt"
tags        = ['ckad', 'exam', 'crack', 'kubernetes', 'cloud', 'devops']
topics      = ['Certified Kubernetes Application Developer (CKAD) Exam']
description = "Tips for cracking the CKAD exam in first attempt"
slug        = 'crack-ckad-exam'
author      = "Simon"
+++

# Intro 

It all started when I decided to learn Kubernetes few months ago.
Then, Paolo M, asked me if I want to take the CKAD exam. 
And, as someone who loves challenges, on 20th December 2019, I took the Certified Kubernetes Application Developer (CKAD) exam, and 1 day later I got certified. 😄

It was one of the most striking exams that I have ever taken, because you need to be quick and manage **19** hands-on questions in **2** hours (6.315789474 min / task 🔥).

So, you need to solve them by using only a terminal and an editor in a specific cluster. And you really need to familiarize yourself with K8s for that. 🙂
But, no worries; in my opinion, I think it is not that complicated as an exam. Having also a **66%** passing score, to me it's achievable.

![](/posts/logo_ckad.png)

# Crack

If you have a clear picture of Kubernetes, some of its most important concepts and want to focus in the exam, I think this **[repository](https://github.com/dgkanatsios/CKAD-exercises)** is the best k8s CKAD sample exercises which cover all parts of the exam.
This [course](https://linuxacademy.com/cp/modules/view/id/305) from Linux Academy can also help you prepare for the exam.

**1.** The most important thing that I would like to suggest is using `kubectl run` and `kubectl create` to create resources, rather than trying to write them on your own. In case you have to edit manifest, use _dry-run_ and _-o yaml_ flags to save the yaml file, then edit it. ⚡️


**2.** Save some time using `alias k=kubectl` and when typing the resources; use their abbreviated aliases instead. (You can check out "`kubectl api-resources`" for a complete list of supported resources.) ⏳


**3.** Each question refers to a given cluster, so read the question carefully and always remember to execute the context change command. Don't forget to put _-n_ flag aswell. Otherwise, you will enter commands on the wrong cluster or wrong namespace. ⚠️


**4.** When you ssh on a node (you would probably need to gain root access using `sudo -i`), keep in mind that you may need to exit twice, as the first exit may get you out of the superuser mode and the second one will get you out of the node. :vim:


**5.** Get a detailed explanation of resources, as well as the fields you can populate with `kubectl explain --recursive`. ℹ️
️
**6.**  This command can help, when you want to get commands on resource creation: `kubectl run --help` 🤔


**7.** Use the embedded notepad from the exam system, if you skip a question. (I skipped some long questions having only 2%-3% of weight. In my case, questions got progressively harder, so manage your time carefully.) 🗒️


**8.** You should be familiar with navigating around Kubernetes official documentation page. (In the exam, you are allowed to open 1 additional browser tab for Kubernetes docs.) 🧭


**9.** I highly recommend using bookmarks from Kubernetes docs for quick access. (I had created a folder structure for each exam curriculum.) 🔖


**10.** I would suggest to always test the solutions and make sure what you did is correct. ✔️


# Conclusion


Reading and watching for K8s will not be enough, in case you do not practice. Thats the key. 🎯

Best of luck! 💪

![](/posts/Simon-Gjetaj-CKAD.jpg)
