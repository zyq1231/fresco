      subroutine gauss(a,b,npoint,xri,wri)
      implicit real*8(a-h,o-z)
      real*8 xg(200),wg(200),xri(200),wri(200)
      call setmgl(npoint,xg,wg)
      do 20 j=1,npoint
      xri(j) = (a+b)/2.d0 + (b-a)/2.d0*xg(j)
      wri(j) = (b-a)/2.d0*wg(j)
   20 continue
      return
      end
