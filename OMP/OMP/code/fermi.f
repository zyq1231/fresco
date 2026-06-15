      real*8 function fermi(E,rho,iset)
      implicit real*8(a-h,o-z)
*     Bauge modification PRC 58 page 1120
!       E0=10.d0
      E0=9.0d0
      ae=2.0d0
      fermih=rho*(-510.8d0+3222.d0*rho-6250.d0*rho*rho)
      fermil=-22.d0-rho*(298.52d0-3760.23d0*rho+
     +         12345.82d0*rho*rho)
      fwt=1.d0/(1.d0+exp((E-E0)/ae))
      fermi=fwt*fermil+(1.d0-fwt)*fermih
      return
      end
