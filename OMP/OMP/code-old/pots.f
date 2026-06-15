      subroutine pots(E,rho,iset,V0,W0,V1,W1,rmtilde)
      implicit real*8(a-h,o-z)
      real*8 a(3,3),b(3,3),c(3,3),d(4,4),f(4,4),ImN
      common/arrays/a,b,c,d,f
      ef=fermi(E,rho,iset)
      V0=0.d0
      ReN=0.d0
      rmtilde=0.d0
      do i=1,3
       do j=1,3
        con=rho**i*E**(j-1)
        V0=V0+a(i,j)*con
        ReN=ReN+b(i,j)*con
        rmtilde=rmtilde+c(i,j)*con
       enddo
      enddo
      rmtilde=1.d0-rmtilde
      V0P=0.d0
      do i=1,3
       do j=2,3
        con=(j-1)*rho**i*E**(j-2)
        V0P=V0P+a(i,j)*con
       enddo
      enddo
      rmstar=1.d0-V0P
      W0=0.d0
      ImN=0.d0
      do i=1,4
       do j=1,4
        con=rho**i*E**(j-1)
        W0=W0+d(i,j)*con
        ImN=ImN+f(i,j)*con
       enddo
      enddo
*     dd=100.d0
*     if(iset.eq.1) dd=600.d0
!       dd=625.d0
      dd=126.25d0
      W0=W0/(1.d0+dd/(E-ef)**2)
      ImN=ImN/(1.d0+1.d0/(E-ef))
      rmbar=rmstar/rmtilde
      V1=rmtilde*ReN
      W1=ImN/rmbar
      return
      end
