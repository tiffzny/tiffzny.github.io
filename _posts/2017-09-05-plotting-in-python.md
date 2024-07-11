---
layout: post
title: Introduction to using Python for Plotting
date: 2016-11-17 10:00:00-0400
inline: false
---

> [!CAUTION]
> Realize, I wrote and published this in 2017 - not everything may be up-to-date if you're reading this in the far future.

> [!CAUTION]
> This is an *unfinished* post, and referenced to [Anneya Golob's Python posts](https://ap.smu.ca/~agolob), which are now offline. I've kept this post up for the sake of completeness (of an incomplete post...). And, maybe I'll come back and update it. 

I’ve had a few requests to post a simple tutorial about how to use Python to plot data, since I am constantly raving about how much I love using Python. Python is an excellent, free computing language that allows its users to do a huge variety of things. In astronomy in particular, the code, functions, and libraries that the community has written makes Python the preferred language for many scientists.

In this post, I hope to introduce someone who may never have used a programming language before to Python, including some of the most useful packages in data science: Numpy and Matplotlib. Don’t worry that you might not have any idea what that means for now, as you’ll soon learn (I hope!)

# Contents

1. [Getting Started](#getting-started)
	1. [Obtaining Python](#obtaining-python)
	2. [Got Anaconda - Now what? How is this useful?](#now-what)
	3. [What do we want to plot?](#what-plot)
2. [Now, plotting!]{#plotting}

# Getting Started {#getting-started}

Before I begin, I want to point out that [Anneya Golob](https://ap.smu.ca/~agolob) has some excellent Python posts here (Note: I realize the links are broken, such is life on the internet!):
* [Getting Started with Python](http://ap.smu.ca/~agolob/phys2300/blog/getting-started-with-python/)
* [Why Learn Python?](http://ap.smu.ca/~agolob/phys2300/blog/why-learn-python/)
* [Plotting Data and ErrorBars and Fitting a Line](http://ap.smu.ca/~agolob/phys2300/blog/climate-change/)
* [Moore’s Law: Nonlinear Fitting](http://ap.smu.ca/~agolob/phys2400/blog/exponentialFit/)

Now, let’s get on to some basic plotting tutorials. First, I’d like to introduce you to Python. I’m going to be working with **Python 2.7**, even though Python 3(+) is the newest version. This is really just personal preference, and *most* of the the language works the same, save for a few small changes (the biggest change you’ll find is with the `print` statements, where you need to use `print(what_I_want_to_print)` rather than `print what_I_want_to_print` – but we’ll get to this later!).

# How do you "get" Python? {#obtaining-python}

Most unix-based environments (looking at you, MacOS!) have Python built-in. You can open up a terminal, type `python`, hit enter, and you’ll be taken into a Python environment. However, that’s typically not the easiest way to program, especially if you’re just starting-out. For that reason, I recommend using an IDE like Spyder. IDEs are “Integrated Development Environments,” but can really just be thought of fancy text-editors that help you run programs.

> [!TIP]
> I recommend that you download [Anaconda](https://www.anaconda.com/download), since it will automatically install useful packages as well as Spyder, which is an IDE that I *highly* recommend.

# I’ve downloaded Anaconda: Now what? How is it special? {#now-what}

It’s almost time to tackle the problem you’d like to solve! Let’s introduce some fun (useful!) packages included with that Anaconda installation.

**NUMPY:**

This is likely the package that I have used the *most* over the last 3 years that I’ve been using Python for science-related purposes. If you’ve used other programming languages like C++ or Java, you’ll likely understand how useful but also how tricky arrays can be to use. Let me back-up: Arrays are like lists of data that make it easy to keep track of lots of pieces of information in a single variable. Here’s an example of an array that contains the values 1 through 10:

```
arr = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
```

Simple, right? It’s just a simple data structure. The problem in languages like C++, though, is that if you tell the program to write the contents of `arr` to the screen, you have to use all of this code:

```
for each value in arr:
    print arr[value]
```

where I’ve used “pseudocode” in the example above – it’s not real code in any language, but just helps illustrate my point in “english” terms. You would have to use a loop to go through every value of the array in order to do anything with the values in the array. If you just tried:

```
print arr
```

you would have a weird hexadecimal number printed to the screen, because the *name* of that array actually is a *pointer* to the location of that array in memory, it doesn’t store information about the contents of the array – only it’s position in memory. Complicated.

To illustrate further, if we wanted to multiply each value by 9 and then print the new value, we would have to do a similar procedure:

```
for each value in arr:
    arr[value] = arr[value] * 9.
    print arr[value]
```

You can see how this might get bothersome if we wanted to do lots of processing on this dataset.

The ***brilliant*** thing about Numpy arrays (and the reason to use Numpy!) is that this bothersome procedure illustrated above is not needed. If you want to print the entire array, all you need to do is:

```python
print arr
```

and the printed information you'll get from the screen is:

```
array([ 1,  2,  3,  4,  5,  6,  7,  8,  9, 10])
```

Super! Just what we were looking for. What about the complicated procedure when we wanted to multiply each value by 9? Thankfully, all you need to do is:

```python
arr = arr * 9
print arr
```

and the result is:

```python
array([ 9, 18, 27, 36, 45, 54, 63, 72, 81, 90])
```

Which is *way* easier than the method used before! It’s ***because of these simple arrays*** that Numpy is so useful.

I want to say that again, because it’s important. *It’s the ease of manipulating Numpy arrays that make them so desirable to use!*

**MATPLOTLIB:**

Matplotlib is the package that allows us to make easy plots, and I’ll go through it more later. Nothing super interesting to explain right now (even though I think this is super neat!), but I’ll guarantee that any plot you could ever hope to make (scatter plot? pie chart? density plot? postage-stamp sized subplots of images?) will be possible.


# What do we want to plot? {#what-plot}

This will depend on whatever you’re attempting to accomplish. For illustrative purposes, I will use an example dataset of galaxy velocities and distances in order to find the Hubble Constant using Hubble’s Law: $v=Hd$ where $v$ is the galaxy’s velocity and $d$ is the distance to that galaxy. $H$ is the Hubble Constant and is quite important in astronomy because it allows us to understand how quickly the universe is expanding.

> [!TIP]
> The dataset can be downloaded [at this link](assets/python-tutorial-assets/Hubble_Law_Data.txt), and is reproduced below.

```
# Hubble_Law_Data.txt
#
# Columns: 
# 0: velocity [km/s]
# 1: distance [Mpc]
#
# For Hubble's Law: v = H * d, where H is the Hubble Constant
#
4975  80
335   8
4740  84
8579  127
6728  100
6820  95
6225  90
10197 129
7428  106
1508  20
872   21
11757 190
7313  108
9834  131
```

The goal will be to measure the value of $H$ by plotting the dataset above.

# Now, we'll get plotting! {#plotting}

Now that we have downloaded Python and know what we *want* to do (plot the dataset and see if we can find $H$!), we can use our plan to build the code.

Here’s the plan of action:

1. Load the dataset into Python
2. Use the linear relation $v=Hd$ to determine $H$, since we are given $v$ and $d$ in the data file
3. Plot the dataset
4. Add a line of best fit to the dataset by using $H$ determined previously

At the beginning of the program, we’ll have to import some external libraries – `numpy` and `matplotlib` that I mentioned previously:

```python
import numpy as np
import matplotlib.pyplot as plt
```

These two lines are where we `import` the two packages I described previously, and we give them shortened “nicknames” to easily reference them later.

Now, we can get to the meat of the program. Our first step is to load the dataset into Python. Right now, it’s just a file with two columns of text, so we have to give it to the program. Luckily, numpy has *functions* that do just what we’re looking for. Specifically, we will use `np.loadtxt` to load the text file into the program.

```python
data = np.loadtxt('Hubble_Law_Data.txt', unpack=True)
```

Here, we are loading the contents of the datafile into the array called `data`. The first argument is the file name, and the second argument - `unpack=True` - tells the function to load the columns into the array first, instead of row-first. You’ll see what I mean below (hopefully):

If we take a moment to look at the contents of the data file by asking the program `print data`, we’ll see:

```
[[  4.97500000e+03   3.35000000e+02   4.74000000e+03   8.57900000e+03
    6.72800000e+03   6.82000000e+03   6.22500000e+03   1.01970000e+04
    7.42800000e+03   1.50800000e+03   8.72000000e+02   1.17570000e+04
    7.31300000e+03   9.83400000e+03]
 [  8.00000000e+01   8.00000000e+00   8.40000000e+01   1.27000000e+02
    1.00000000e+02   9.50000000e+01   9.00000000e+01   1.29000000e+02
    1.06000000e+02   2.00000000e+01   2.10000000e+01   1.90000000e+02
    1.08000000e+02   1.31000000e+02]]
```

which, looks like a mess, but we can break it down into two separate arrays (if you keep the brackets all organized...). The first is 

```[ 4.97500000e+03 3.35000000e+02 4.74000000e+03 8.57900000e+03 6.72800000e+03 6.82000000e+03 6.22500000e+03 1.01970000e+04 7.42800000e+03 1.50800000e+03 8.72000000e+02 1.17570000e+04 7.31300000e+03 9.83400000e+03]```

and the second is

```[  8.00000000e+01   8.00000000e+00   8.40000000e+01   1.27000000e+02
    1.00000000e+02   9.50000000e+01   9.00000000e+01   1.29000000e+02
    1.06000000e+02   2.00000000e+01   2.10000000e+01   1.90000000e+02
    1.08000000e+02   1.31000000e+02]```
    
These can be accessed by `data[0]` and `data[1]` respectively. Remember, Python arrays are 0-indexed, meaning the "first" position in an array is given the index 0.

