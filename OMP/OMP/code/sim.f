      subroutine sim(fa,res,m,n,h)
*------------------------------------------------------------------------
*     subroutine does the integral of fa stored
*     in the arrays of the same name using simpsons rule. the step length
*     is h and the integral is between the elements m and n of the arrays
*     only. resulting integral is placed in res.
*------------------------------------------------------------------------
      implicit real*8(a-h,o-z)
      dimension fa(8000),dq(8000)
      do 90 i=m,n
      dq(i)=fa(i)
   90 continue
      rq1=dq(m+1)
      rq2=dq(m+2)
      i=m+3
   98 continue
      if(i.ge.n) go to 99
      rq1=rq1+dq(i)
      rq2=rq2+dq(i+1)
      i=i+2
      go to 98
   99 continue
      res=0.33333333333d0*h*(dq(m)+4.d0*rq1+2.d0*rq2-dq(n))
      return
      end
