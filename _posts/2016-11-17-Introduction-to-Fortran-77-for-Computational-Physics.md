---
layout: post
title: Introduction to Fortran 77 for Computational Physics
date: 2016-11-17 10:00:00-0400
inline: false
---

*This post goes along with a tutorial given by Tiffany to SMU Astronomy/Physics students on Friday, Nov. 18th, 2016, in order to introduce them to what will be seen in the Computational Physics (PHYS 3210) class in 3rd-year.*

<img src="/assets/fortran-tutorial-assets/electric-dipole.jpg" width="100%">

This is a simple (yet verbose) introduction to Fortran 77, using the example of calculating an electric field at certain points, assuming we have the data to do so. The tutorial I’m showing here is ***largely*** based on the tutorial given by Chris MacMackin in 2014, available [here, on the SMUAPS webpage.](http://ap.smu.ca/~smuaps/an-introduction-to-modern-fortran-programming.html) (Note: link broken) Chris’s tutorial covers modern Fortran, while I deal with just Fortran 77. There are other bits of information available in Chris’s tutorial as well that you won’t find here, so I recommend scrolling through his after reading through this page.

What we will do first is identify the problem we would like to solve, then examine ways to solve this program numerically (or with a computer). Next, I’ll relate this directly to how we can use Fortran 77 to read a data file and perform the calculations. We’ll look at the results at the end, and consider some extra helpful notes.


# Contents

1. [Files for Download](#Files)
2. [Background](#Background)
3. [The Problem](#Problem)
4. [Programming and Algorithm](#Algorithm)
	1. [Declaring Variables](#Variables)
	2. [Reading Data](#ReadingData)
	3. [Finding the Derivative](#Derivative)
	4. [Write Data to an Output File](#WriteData)
	5. [Statistics of the Data](#Statistics)
5. [Compiling and Running a Fortran Program](#Compiling)
6. [Conclusion](#Conclusion)
7. [Extra Notes](#Notes)
8. [Footnotes](#Footnotes)


---
# Files {#Files} 
**Before we get started,** here are the relevant files I’ll be working with: [potentialfield.f](/assets/fortran-tutorial-assets/potentialfield.f), the Fortran code and [in.dat](/assets/fortran-tutorial-assets/in.dat), the data file. The data file has two columns: the first column is position, and the second column is the value of the potential at that position. You should keep the code and the data file in the same folder.

---


# Background {#Background}

Often, an equation can’t be solved as easily on a computer as when it’s written on paper. For instance, when you take a derivative, you know the process and you know the rules of derivatives, so it’s easy to do. We know the derivative of $x^2$ is $2x$, and we know the derivative of $e^x$ is $e^x$, but how do you tell a computer all of these rules? What if we don’t have a continuous function, but rather a discrete number of points (such as in a data set)?

With a data set, the process becomes more complicated and we have to think about the math we will tell the computer to perform. Here, I’ll show you how to use Fortran (the ‘77 version), to solve a physics problem (related to derivatives). The great thing about Fortran is that it is mostly like reading plain English, something that languages like C++ or Java can’t say. So, reading and writing in Fortran is typically less of a daunting task than we might think.


# The Problem {#Problem}

We have [data](/assets/fortran-tutorial-assets/in.dat) of electric potentials at various positions. What we would *like* to do is to calculate the strength of the *electric field** at each position. Recall how the potential and the electric field are related in one dimension:
$$E = -\dfrac{dV}{dx}.$$

As I mentioned before, when we are programming (or “telling a computer to do something”), we must rethink the way in which we do certain calculations. Let’s think about the derivative, and what it means, beyond just the rules to find derivatives. Recall that the derivative is the instantaneous slope at a point. We can relate this to *our* data by finding the slope *around* each data point, in the following way:
$$\dfrac{dV_i}{dx} \approx \dfrac{V_{i+1}-V_{i-1}}{x_{i+1}-x_{i-1}}.$$

Note, this is an approximate method since we have discrete data rather than a continuous function. At the endpoints of our data, we won't have an $(i+1)^{\mathrm{th}}$ point (if we are at the end) or an $(i-1)^{\mathrm{th}}$ point (if we are at the beginning of our data). Therefore, we must change the way in which we calculate the derivative at these points slightly to
$$\dfrac{dV_i}{dx} \approx \dfrac{V_{i+1}-V_{i}}{x_{i+1}-x_{i}} \:\:\: \mathrm{at}\:\mathrm{the}\:\mathrm{beginning,}\:\mathrm{or} \:\:\: \approx  \dfrac{V_{i}-V_{i-1}}{x_{i}-x_{i-1}}, \:\:\: \mathrm{at}\:\mathrm{the}\:\mathrm{end.}$$

Now, we must write the code for these calculations.


# Programming {#Algorithm}

Let’s consider the algorithm we will follow for this program:

1. Declare variables needed in the program
2. Read data from our [in.dat](/assets/fortran-tutorial-assets/in.dat) file, and save the data to arrays
3. Take the derivative of the data, then multiply by -1 to find E
4. Write data to the output file
5. For some extra fun, we’ll then calculate the mean and the standard deviation of the calculated E

Now that we have an idea of the algorithm we’ll follow, let’s get to it.

> [!TIP]
> Read the footnotes. I’ll include useful information there as well.


# Declaring Necessary Variables {#Variables}

I want to make the strong note that this part of the process of programming does *not* need to happen first. Often, variables can be declared as you realize you need them, and that’s entirely fine, but I want to take this time to explain about variable declarations.

Unlike some other programming languages, Fortran requires all variables be declared (with their type and their name) at the very beginning of the program. Here’s the beginning of my program and my declarations for [potentialfield.f](/assets/fortran-tutorial-assets/potentialfield.f)):

```fortran
      program potentialfield
c
      implicit none
c
c  This is where the infile/outfile should be changed if needed
      character*32 infile, outfile
      parameter    (infile='in.dat', outfile='out.dat')
c
      integer      datamax
c Here, we are saying the MAXIMUM # of data rows we will read is
c  1012. Be sure to change this if it is too small for your particular
c  data file.
      parameter    (datamax=1012)
      integer      i, ioval, datasize
c
      real*8       mean, stdev
      real*8       field(datamax), postn(datamax), potntl(datamax)
c
      external     diff, stats
```

Here, you’ll start to notice some of Fortran 77’s syntax. The first line is `program potentialfield`, which tells the computer that I am starting a program. Something interesting that can be discussed on this first line is that the 1st character in any line (except for a commented line), must start in the *7th column.*

Therefore, to start any line, you’ll have to hit “space space space space space space” before starting to write your code.[^1]

[^1]: Yep, every single line. You get really good at hitting the space bar 6 times before starting to type. Then it takes over your life. You can’t write anything before hitting the spacebar six times...

On the second line, you’ll find only a `c`. In Fortran 77, a `c` in the very first column indicates a comment – the entire line will be commented, and the compiler will ignore the code. Additionally, `!` can be used for comments, but is not standard for Fortran 77. You’ll see me use `!` for in-line comments, anyway, and `c` for comments that take up the entire line.[^2]

[^2]: Additionally, none of the lines in your program should be blank. Instead of a blank line, put a `c` in the first column of the line so the compiler ignores the line entirely.

On the next line, `implicit none` tells the compiler that we don’t want any variables in the code without having declared them first. This way, we’ll have an error when attempting to compile this code if the program has a variable that has not been declared. Using `implicit none` in this code is good programming practice.

Now, we’ll get to the meat of this section: The declarations! You’ll see how I declare `character`[^3], `integer`, and `real*8`[^4] types of variables. Something that needs to be pointed out here is that the variables `field`, `postn` (position), and `potnl` (potential) are all *arrays*, and we have declared them as such by giving them a size – in the case of all three variables, the size is `datamax`. In Fortran77, we must declare the sizes of arrays (and strings) at the very beginning. So, we might as well make the arrays `huge`, just in case we need lots of space to store numbers.

[^3]: In my code, I declare the variables `infile` and `outfile` as `character*32`. Here, the 32 means that I want to reserve 32 spaces for the name of infile or outfile to be stored in. Therefore, the maximum length of these *strings* is 32. This can be changed to whatever is necessary for any situation.

[^4]: In Fortran, `real*8` means double-precision, which means that the computer saves 64 digits of the number. It is just a precise way of storing a number that requires a decimal point. You’ll use numbers like `1.0d0` or `8.617d-5` in your code, where the `d` acts as a “10 to the power of” the same way that `e` in `6.2e23` does. You’ll *always* have to use the `.` and `d` in numbers that are declared as `real*8`.

Additionally, I use `parameter` to give the variable `datamax` a specific and constant value, which cannot be changed later in the program. The final line declares the names of the external subroutines I’ll be using (which will appear later!).


# Reading Data {#ReadingData}

Now that we have data declared[^5], we can start to write out the instructions for the computer. The first step is to make sure the data is read into arrays so that the program can use it. Let’s examine the relevant part of the code:

[^5]: Remember: The declaration doesn’t actually have to be written *first*. It’s often useful to write part of it, thinking about the variables you’ll need to keep track of, but feel free to go back at a later time to write the declarations (before compiling).

```fortran
c Read in data from the input file, the 'unit' is 10
      open(unit=10, file=infile, status='unknown')
c
c Read elements of the file. We will read from 0 --> datamax, 
c  even though our data file might be smaller than datamax.
c  So, we will keep track of how large the file is by incrementing
c  datasize
      datasize = 0
      do 11 i=1, datamax
        ! end=11 means it will go to the label '12' when file is empty
        read(10,*,end=12) postn(i), potntl(i)
        datasize = i + 0
11    continue
12    continue
c
c Issue a warning if data may have been cut off because of the arraysize
      if (datasize .ge. datamax) then
        write(*,*) 'WARNING: datasize is same as datamax. Data may ',
     1             'have been truncated'
      end if
c
c We are done with that file, so close it now
      close(10)
```

The second line is the command to `open` the data file, whose name we have saved to the variable `infile`. We open the file with the `open` command and save it to a `unit`, which we call `10`. Fortran 77 wants to have an integer by which to reference files, so we’ll remember that this file is unit `10` when we want to read the data a few lines down.[^6]

[^6]: You’ll see that Fortran 77 really likes to use integers to represent or *label* specific things. You’ll see it when opening files, when wanting to jump to a specific spot in the code, and in `format` statements.

At the beginning of the program, we have no idea how many data points are in `infile`. So, I use the variable `datasize` to keep track of the length of the data file, which is incremented in the `do-loop`. The `do-loop` is simplest type of loop, and the structure is as follows:

```
      do LABEL STEPPER=START, END[, SKIP]
        code to execute in loop
        more code
        something else
LABEL continue
```

`LABEL` is an integer that corresponds to the “label” of the `continue` command that signifies where the program should go at the end of the loop. `STEPPER` is a variable that is declared to start at a certain value, `START`, and will be incremented by either 1 or `SKIP` (*if* a `SKIP` is provided)[^7] until the value of `STEPPER` is greater than `END`. When `STEPPER` is greater than `END`, then the loop ends and the program jumps to the `LABEL` to keep going through the rest of the code.

[^7]: Typically, [ ] is used in displaying code to indicate something that is optional. For example, if a program asks for: First Name [Last Name], it would mean it *required* your first name, but that the Last Name is optional to provide – it’ll run the same with or without it, and providing it just gives the computer more information to be used.

In the loop, we read the data from the file into the arrays we have declared. A very important note is that the indices of arrays in Fortran **start at 1, not 0**, unlike many other programming languages (such as Python). For example, if I had the array:

```
(13, 5.4, 'banana', 3, 0.14, 0.00159)
```

the **index** of `13` would be **1**, *not* 0! Therefore, when I read data from the file into the arrays, I want to put the first data point in index 1 of the array, the second data point in index 2, etc.

Here is where we get to the `read` command. In this line, we `read` from `10`, which was the label we gave to the `infile` that we are reading data from (I said we needed to remember it!), and put the information we read into `*`, which is specified directly after the `read` command, and then we will jump to label `12` if we come to the end of the file. The first value that is read in each line goes into the array `postn` (as it should), and the second value read goes into the array `potnl` (as it should). You can see how I included the labels `11` and `12` after the loop, to indicate places where the program needs to jump to if certain conditions are met (like the loop ending or finding the end of the file).

Next, I write a warning to the standard output (usually the screen, or the terminal window you’re working in) if more data points were read than the maximum size we gave to the arrays. Then, since we are all done reading data from `infile`, I close the file.[^8]

[^8]: It’s bad practice to not `close` a file that was `open`ed by a program. If a file is open in one program, it is either inaccessible by other programs or multiple programs will attempt to use it at once – both are very bad. We want to be sure we keep files open for only as long as we need.


# Finding the Derivative {#Derivative}

Our next step in the algorithm is to find the derivative of the potential at each position, and then multiply that derivative by -1 to find the value of the electric field, `field`, at the position. Here is the relevant bit of the code from `potentialfield.f` that does just that:

```fortran
c Now, calculate the negative derivative of the input data, to find
c   the value of the field at each point
c Here, 'field' will be "returned" to us -- changed in the way we want
      call diff(postn, potntl, datasize, field)
      do 13 i=1, datasize
        field(i) = -1.0d0 * field(i)
13    continue
```

But, this seems too simple, doesn’t it? All it took to find the `field` was the command `call diff`. If you thought that, you’re certainly correct. The `call` command “calls” a subroutine called `diff`, which is short for “differentiate.” The arguments, or the values that we are giving to the subroutine, are listed in the parenthesis.[^9] In my `diff` subroutine, shown below, the variables `postn`, `potntl`, and `datasize` are used to calculate the values of `field`. Recall, at this point, that the variable `field` has *no* values assigned to it yet – but it will be filled with values when the program returns from the subroutine `diff`. Let’s take a look at how the subroutine `diff` looks in the code:

[^9]: An *important* thing to remember about arguments (the variables that are passed between subroutines or functions) in Fortran are not **copies** of the variables, but rather **the variables themselves**. Therefore, if the value of a variable is changed inside a subroutine, *it’s changed forever, everywhere in the program!*

```fortran
c=======================================================================
c SUBROUTINE - DIFF
c -----------------
      subroutine diff(x, y, size, deriv)
      implicit none
c
c This estimates the first derivative of some discrete data. Returns
c  the double-precision array 'deriv' after modifying it here.
c     
c     Arguments:
c         x - the independent variable
c         y - the dependent variable
c         size - the size of x, y, and 'ans'
c         deriv - the 'derivative' -- the array we will be returning
c
      integer size, i
      real*8  x(size), y(size), deriv(size)
c
c-----------------------------------------------------------------------
c
c Calculate the derivative for the first data point
      deriv(1) = (y(2) - y(1)) / (x(2) - x(1))
c
c Calculate the derivative for all of the middle points
      do 10 i=2, size-1
        deriv(i) = (y(i+1) - y(i-1)) / (x(i+1) - x(i-1))
10    continue
c
c Calculate the derivative of the last data point
      deriv(size) = (y(size) - y(size-1)) / (x(size) - x(size-1))
c
      return
      end
c=======================================================================
```

You may notice that the entirety of this subroutine is only actually just 5 lines of code, with lots of comments for explanation (in other words: much more simple than it looks!). In this subroutine, I’ve implemented the equations for derivatives (on computers) that we worked out before. For the first value of the derivative, I have
$$\dfrac{dy(1)}{dx} = \dfrac{y(2)-y(1)}{x(2)-x(1)}$$
which was needed for the first data point. Then, I find the derivative of all of the middle points as we described above in the [Problem](#Problem) section. To do this, I must loop through all of the data points in the arrays that we have saved. I know I must loop from `2` – the second index, since we already took care of the *first* point – to `size-1`, which is 1 position below the end of the array. After the loop is through, I calculate the last data point similarly to the first, but using the last two data points instead of the first two for the calculation (the same as described before).

Then, we’re done. We have calculated the derivatives at all points, now we can `return` to the original program and `end` the subroutine.

We we get back to our original code, all that is left to do is to loop through all of the indexes of our newly-filled array `field` and multiply the values by -1 to get the value of E!


# Write Data to an Output File {#WriteData}

Next, we will save the calculated data to a file, in case we ever need to access it in the future. Our goal is to write a file with two columns: the first column being position, and the second column being the calculated electric field at that position. Here’s the relevant bit of code that does that:

```fortran
c Next, write out answer to the output file
      open(unit=10, file=outfile, status='unknown')
      write(10, *) '# Position, Field Strength' ! header for file
      do 14 i=1, datasize
        write(10,2000) postn(i), field(i)
14    continue
c 
      close(10)
```

The majority of this code is similar to bits of code that we have seen before. We see the `open` command, a `do-loop`, and another `close` command. The only new command seen here is the `write` command, which is how we tell the program to “write” to something.

The way that the write command works is the same as the read command: we have

```
write(LOCATION, STUFF-TO-WRITE)
```

where `LOCATION` is where the program is writing *to*, and `STUFF-TO-WRITE` is what the program is *going to write*. In my first `write` statement, I set `STUFF-TO-WRITE` to be `*`, so the program looks immediately after the `write` statement to see what it wants to write. In our case, I’m writing a comment (started with a `#`) about what the file contains.[^10] However, in the second `write` statement, I set `STUFF-TO-WRITE` to be `2000`. If you didn’t already guess, `2000` is a *label* that corresponds to a `format` statement, which is found near the end of the code and looks like:

```fortran
c-----------------------------------------------------------------------
c      Format statement. 1 'page', 2 numbers, with 22 digits before the
c         decimal, and 15 digits after the decimal
2000  format(1p2g22.15)
2010  format('STATS: The average electric field strength was ',/
     1       ,'STATS:',1p1g12.5,' N/C with a sample standard deviation'
     2       ,/,'STATS: of ',1p1g12.5,' N/C'
     3       ,/,'STATS: This was calculated using ',i4,' data points.')
c-----------------------------------------------------------------------
```

Though this looks complicated, it isn’t really. I give the label `2000` to the first `format` statement, so when I tell the program to `write(10, 2000)`, it will follow this format when writing. The `1p2g22.15` in the parenthesis tells the program to write 2 `real*8` values, with 15 digits past the decimal point.[^11] The second `format` statement is for the printing of statistics that I will explain below.

Here, we also see how to continue lines in Fortran. Since Fortran 77 only allows 72 characters per line (crazy, I know), you’ll often need to continue your code on multiple lines for it all to fit. In Fortran 77, we use integers in the *6th column* to show that we are continuing lines, the same way I’ve done above.

Now, we’ve printed all of our data to the file `outfile`, hooray! At this point, we’ll just calculate some statistics about the data for fun.

[^10]: Interestingly, I don’t think that Fortran allows comments like this (with the `#`) in files that it’s reading from. Try it - You’ll likely get an error like I did.
[^11]: There’s a LOT more that goes into these format statements, but I recommend a good Google to figure out anything if you need. Likely, you’ll just follow whatever `format` statements you find here or that your professor has, and hope for the best.


# Statistics of the Data {#Statistics}

Next, I want to calculate the mean and the standard deviation of the electric field and print those results right to the screen. The relevant bit of code is:

```fortran
c Calculate statistics, and output the results to the screen
      call stats(field, datasize, mean, stdev)
      write(6, 2010) mean, stdev, datasize
```

As with differentiating, I’ve just called a subroutine `stats` to do the dirty work of calculating things for me. The variables `mean` and `stdev` are the ones that will be changed in the subroutine and then given back to me with proper values. Below, I’ve included the subroutine `stats`.

```fortran
c=======================================================================
c SUBROUTINE -- STATS
c -------------------
      subroutine stats(array, size, mean, stdev)
      implicit none
c
c Finds the average and standard deviation of the data in the passed
c  array. The 'mean' and 'stdev' are given back to the place where
c  they were called from.
c
c     Arguments:
c        array - the 1-dimensional array of real*8 values containing
c                the data to be averaged
c        size  - the 'size' of 'array'
c        mean  - this will be "returned", and will be a real*8 value
c                of the mean
c        stdev - this will be "returned", will be a real*8 value of std
c
      integer size
      real*8  array(size)
      real*8  mean, stdev
c
      integer i
      real*8  tot
c-----------------------------------------------------------------------
c Compute the mean
c     First, get total
      tot = 0.0d0
      do 10 i=1, size
        tot = tot + array(i)
10    continue
c     Then, divide by size of array
      mean = tot / dble(size)
c
c Compute the stdev
      tot = 0.0d0
      do 11 i=1, size
        tot = tot + ( array(i) - mean )**2
11    continue
      stdev = sqrt(1.0d0/dble(size-1) * tot)
c
      return
      end
c=======================================================================
```

Now, this should all be code that we’ve seen before. The only new bit of code might come near the end, right after the `11 continue` line. In this line, I want to be sure to avoid *mixed arithmetic*, which means I want to be sure I don’t do any math with an `integer` and a `real*8` variable, etc. So, I use the command `dble( STUFF )` to be sure that the value `STUFF` is a double-precision (or `real*8`) value. The equations which I am following are the typical equations for finding the mean and the standard deviation, as follows:

$$\mathrm{mean}=\bar{x}=\dfrac{1}{N}\Sum^N_{i=1}x_i, \:\:\: \mathrm{stdev}=\sigma=\sqrt{\dfrac{1}{N-1}\Sum^N_{i=1}(x_i-\bar{x})^2}.$$

And that's it! We're all finished with the program we wanted to accomplish!

Now how do we run it...?


# Compiling and Running a Fortran Program {#Compiling}

Ok, we’ve gotten pretty far. We have a nice program written that calculates something physical, using computational methods - incredible! The next step is to compile the code.

> [!WARNING]
> This section is relevant for Unix-based operating systems, like MacOS or Linux systems, or for use on the SMU A&P servers.

On the A&P servers like Mars or Andromeda (and everywhere else, in general), the main Fortran compiler is `gfortran`.[^12] The process to compile the code is simple. Type `gfortran filename.f` into a command-line, press `enter`, and the program will compile (assuming there are no errors...). If there are errors, warning and error messages will pop up and attempt to describe what went wrong. Often, these error messages aren’t very useful. C’est la vie.

[^12]: `gfortran` can be downloaded onto your own computer. A good way to see if it already exists on your machine is to open a terminal (on a Unix-based machine) and type `gfortran` then hit `enter`. If you get an error saying the command is not recognized, you’ll have to download it – or, just always use the A&P servers (like Mars or Andromeda).

Once you compile your program, you will notice a new file in your directory called `a.out`, which is your executable program!! To run this program, type `./a.out` into your command-line. Magic! Your program will run! If you used the same `in.dat` that I did, this is the output you’ll see:

```
STATS: The average electric field strength was 
STATS:  20.000     N/C with a sample standard deviation
STATS: of  6.78745E-15 N/C
STATS: This was calculated using   21 data points.
```

Awesome! We’ve written code to solve a problem and to analyze data! If you want to give your executable file a certain name, use the code

```
gfortran potentialfield.f -o potentialfield
```

which will create an executable called `potentialfield`, and to run this file, you should type `./potentialfield` into your command line and press `enter`.


# Conclusion {#Conclusion}

I know this has been a very long introduction to the way Fortran 77 behaves, but I hope that this exposure to Fortran 77 now (before Computational Physics begins) will make you more comfortable dealing with the code you could see in a Fortran-based computational physics class.

It’s important to remember that Fortran (even the ‘77 version) is just a tool that can be used to solve a problem. Fortran is a language that runs quite quickly (compared to some languages like Python), and is excellent to solve math and physics problems with for this reason. [Dr. Thacker](https://ap.smu.ca/~thacker) and I have worked with galaxy simulation code HYDRA which is written in Fortran 77, and it’s what I used for my honours thesis work. Fortran isn’t necessarily my favorite language to work in, but it’s the language that makes the most sense for the work that it is used for – it’s fast, it’s easy to write, and it’s simple.


# Extra Notes {#Notes}

**THAT MAY OR MAY NOT HAVE MADE IT INTO THE REST OF THE PAGE:**

1. Fortran 77 only allows 72 characters per line. Anything over 72 characters will cause an error. It might be a good idea to use a text editor that shows the column number? I use [BBEdit](https://www.barebones.com/products/bbedit/) and I can add a vertical line at column 72, so I know I won’t ever type too far.
2. For comments, use `c`. Using `!` for in-line comments works (and I use it), but is not part of the Fortran 77 “standard.”
3. All Fortran 77 code must start in the 7th column. Labels must start at the first column, and “continuation” indicators must be in 6th column. Not the easiest to get used to, but it’ll be ok.
4. In declarations, `parameter` means the value is FIXED and cannot be changed ever in the program. However, `data` just means you’re giving something an initial value, it’s NOT fixed forever.
5. I believe that Unit 6 is standard output (to the screen), and Unit 5 is the standard input (what you could enter with your keyboard).
6. Original Fortran 77 didn’t allow variable names >8 characters, but compilers usually let it slide now.
7. In my program, I always ended `do-loops` with a label and then a `continue` statement. However, although not standard Fortran 77, `end do` is also an acceptable way to end do-loops.
8. As mentioned elsewhere (but important enough to mention again!), Fortran arrays start at index 1, not 0 like most other programming languages.
9. If something is passed to a subroutine, the *actual* variable is passed, not just a copy of the value. In other words, Fortran passes by *reference*, **not** by *value*. This [image](https://i.stack.imgur.com/QdcG2.gif) is a good example of the difference between passing by reference and by value.
10. Instead of leaving blank lines in your code, just add a `c` at the beginning of the line, commenting out the entire line.
11. Do not do mixed arithmetic! It is actually possible to cause math errors if you do this. For instance, if I attempt to divide a double-precision value by an integer, it is unlikely that the correct result is returned.
12. Elements of arrays can be accessed with ( ), not [ ] like in Python or C++.


# Footnotes {#Footnotes}