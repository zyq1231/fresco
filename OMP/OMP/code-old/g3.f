      real*8 function g3(rmag,t2,r2)
      implicit real*8(a-h,o-z)
      g3=rmag*exp(-r2/t2)
      return
      end
