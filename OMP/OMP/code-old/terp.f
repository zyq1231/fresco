      real*8 function terp(r,fun,rgrid,npts,ndim)
c------------------------------------------------------------------------------
c     this function calculates, by interpolation, the value of a real
c     function at an arbitrary point r, when the value of the function
c     (stored in array fun) is known on a grid of points. The values of the
c     npts points at which the function is known is stored in array rgrid.
c     ndim is the externally defined dimensions of the arrays fun and rgrid
c     JAT routine of some vintage.
c------------------------------------------------------------------------------
      implicit double precision(a-h,o-z)
      real*8 fun(ndim),y1,y2,y3,y4,y5,y6
      double precision rgrid(ndim)
      do 30 k=1,npts
      nst=0
      if(rgrid(k).lt.r) goto 30
      nst=max0(k-3,1)
      goto 33
   30 continue
   33 if(nst.gt.npts-5) nst=npts-5
      x1=rgrid(nst+0)
      x2=rgrid(nst+1)
      x3=rgrid(nst+2)
      x4=rgrid(nst+3)
      x5=rgrid(nst+4)
      x6=rgrid(nst+5)
      y1=fun(nst+0)
      y2=fun(nst+1)
      y3=fun(nst+2)
      y4=fun(nst+3)
      y5=fun(nst+4)
      y6=fun(nst+5)
      pii1=(x1-x2)*(x1-x3)*(x1-x4)*(x1-x5)*(x1-x6)
      pii2=(x2-x1)*(x2-x3)*(x2-x4)*(x2-x5)*(x2-x6)
      pii3=(x3-x1)*(x3-x2)*(x3-x4)*(x3-x5)*(x3-x6)
      pii4=(x4-x1)*(x4-x2)*(x4-x3)*(x4-x5)*(x4-x6)
      pii5=(x5-x1)*(x5-x2)*(x5-x3)*(x5-x4)*(x5-x6)
      pii6=(x6-x1)*(x6-x2)*(x6-x3)*(x6-x4)*(x6-x5)
  777 xd1=r-x1
      xd2=r-x2
      xd3=r-x3
      xd4=r-x4
      xd5=r-x5
      xd6=r-x6
      pi1= xd2*xd3*xd4*xd5*xd6
      pi2= xd1*xd3*xd4*xd5*xd6
      pi3= xd1*xd2*xd4*xd5*xd6
      pi4= xd1*xd2*xd3*xd5*xd6
      pi5= xd1*xd2*xd3*xd4*xd6
      pi6= xd1*xd2*xd3*xd4*xd5
      terp=y1*pi1/pii1+y2*pi2/pii2+y3*pi3/pii3+y4*pi4/pii4+
     + y5*pi5/pii5+y6*pi6/pii6
      return
      end
