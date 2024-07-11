c=======================================================================
c POTENTIAL FIELD
c
c    AUTHOR: Tiffany Fields (via SMUAPS) 
c
c  modified from Chris MacMackin's original F90 file, available at: 
c  ap.smu.ca/~smuaps/an-introduction-to-modern-fortran-programming.html
c
c    Date: November 2016
c
c    PURPOSE: - Processes data on potential to calculate a field. Then
c             finds some statistics on the field. 
c
c    USE:     - The input file should consist of two columns of data, 
c               separated by spaces.
c               - 1st column: position
c               - 2nd column: potential at that position
c               - All values should be in SI units
c             - The default input file is 'in.dat' and the default 
c               output file is 'out.dat'. 
c               - to change the filenames, change this code!
c 
c=======================================================================
c234567--*---------*---------*---------*---------*---------*---------*--
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
c
c-----------------------------------------------------------------------
c
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
c
c
c Now, calculate the negative derivative of the input data, to find
c   the value of the field at each point
c Here, 'field' will be "returned" to us -- changed in the way we want
      call diff(postn, potntl, datasize, field)
      do 13 i=1, datasize
        field(i) = -1.0d0 * field(i)
13    continue
c
c Next, write out answer to the output file
      open(unit=10, file=outfile, status='unknown')
      write(10, *) '# Position, Field Strength' ! header for file
      do 14 i=1, datasize
        write(10,2000) postn(i), field(i)
14    continue
c 
      close(10)
c
c Calculate statistics, and output the results to the screen
      call stats(field, datasize, mean, stdev)
      write(6, 2010) mean, stdev, datasize
c
      stop
c-----------------------------------------------------------------------
c      Format statement. 1 'page', 2 numbers, with 22 digits before the
c         decimal, and 15 digits after the decimal
2000  format(1p2g22.15)
2010  format('STATS: The average electric field strength was ',/
     1       ,'STATS:',1p1g12.5,' N/C with a sample standard deviation'
     2       ,/,'STATS: of ',1p1g12.5,' N/C'
     3       ,/,'STATS: This was calculated using ',i4,' data points.')
c-----------------------------------------------------------------------
c
      end
c=======================================================================
c
c
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
c
c
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