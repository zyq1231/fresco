      program djlm
c  program to calculate Nucleus-Nucleus potential by using JLM interaction
c  based on Prof. Jeff Tostevin's code
c  by D.Y. Pang, March, 2010
c  calculate volume integral, Nov. 2010
      implicit none

      real*8 :: radP(8000),rhoPn(8000),rhoPp(8000),rhoPm(8000)
      real*8 :: radT(8000),rhoTn(8000),rhoTp(8000),rhoTm(8000)
      real*8 :: a(3,3),b(3,3),c(3,3),d(4,4),f(4,4)
      real*8 :: xrt(200),wrt(200),xmu(200),wmu(200)
      real*8 :: potr(8000),poti(8000)
      real*8 :: pApotR(8000), nApotR(8000), pApotI(8000), nApotI(8000)
      real*8 :: nAR(8000)

      character :: densFileP*40, densFileT*40,guff*4
      character :: nucleon,ans,nucl*12
      real*8 :: ap, zp, at, zt, nt, Ecal, Elab
      real*8 :: rmin, rmax, rstep, rptmax
      integer :: nrmax
      integer :: ilda, iset
      integer :: mqr, mqmu
      real*8 :: zero, one
      real*8 :: tr, ti, t2r, t2i, rmagr, rmagi
      integer :: i, nuc, ijax, ico, ijj, ivalP, ivalT, imqr, imqmu
      real*8 :: rp, rp2, rpt, rpt2, summr, summi, bval, rt, rt2
      real*8 :: Rcc, Rcc2
      real*8 :: pi, at13, rc, vc
      real*8 :: rhot, rhoxn, rhoxp, rhox, alpha, rx
      real*8 :: gg3r, gg3i
      real*8 :: g3, terp
      real*8 :: V0, V1, W0, W1, rmtilde
      integer :: irp, imuP, irt, imuT
      real*8 :: V0P, V1P, W0P, W1P, V0N, V1N, W0N, W1N
      real*8 :: rmtildeN, rmtildeP
      real*8 :: r12,r12S,bval12,bval1B,r2,r2S,r1B,r1BS,r1,r1S,RAB,RABS
      real*8 :: summPr, summPi, summNr, summNi, sumr1R, sumr1i
      real*8 :: potNr1i, potNr1r, potPr1i, potPr1r
      real*8 :: rhoPr1, rhoNr1
      real*8 :: rnAmax
      integer :: ivalnA
      real*8 :: lambdaV, lambdaW, lambdaV1, lambdaW1
      real*8 :: Jv, Jw, ajv(8000), ajw(8000), ajv4(8000), ajw4(8000)
      real*8 :: Jvp, Jwp, Jvn, Jwn, jv4, jw4, rmsv, rmsw
      real*8 :: ajvp(8000), ajwp(8000), ajvn(8000), ajwn(8000)
      real*8 :: ecm, eNorm
c systematic renormalization factors
      real*8 :: Nr, Ni

      common/arrays/a,b,c,d,f

      namelist/basicInfo/ ap, zp, at, zt, Elab, densFileP, densFileT
      namelist/calCtrl/ rstep, nrmax, rptmax, mqr, mqmu, tr, ti, ilda

      print*,' ---------------------------------------------------'
      print*,'JLM local density approximation nucleus-nucleus potential'
      print*,'with sign problem corrected. Dec. 14, 2010'
      print*

      pi=4.d0*datan(1.d0)
      do i=1,1000
       potr(i)=0.d0
       poti(i)=0.d0
       pApotR(i)=0.0d0
       PApotI(i)=0.0d0
       nApotR(i)=0.0d0
       nApotI(i)=0.0d0
      enddo

      read(5,nml=basicInfo)
      read(5,nml=calCtrl)
      write(30,nml=calCtrl)

*     ------------------------------------------------------------
*     print*,' Target mass A and charge Z '

      nt=at-zt
      at13=at**(1.d0/3.d0)
      rc=1.123d0*at13+2.35d0/at13-2.07d0/at

c systematic renormalization factors
      Nr=0.4226d0+0.004235d0*(elab/ap)
      Ni=1.2196d0

      ecm = (elab/ap)*at/(at+1.0d0)

      eNorm = elab/ap

*     print*,' Lab Energy (MeV/nucleon) '

      Ecal = Ecm
      write(6,603) Ecal
  603 format("nucleon energy in calculation is: ", f8.3, " MeV")

      lambdaV = 0.951d0+0.0008d0*dlog(1000*eNorm)
     &              + 0.00018d0*(dlog(1000*eNorm))**2

      if(eNorm.ge.80.0d0) then
        lambdaW= (1.24d0-1.0d0/(1.0d0+dexp((eNorm-4.5d0)/2.9d0)))
     &           *(1.0d0+0.06d0*dexp(-((eNorm-14.0d0)/3.7d0 )**2))
     &           *(1.0d0-0.09d0*dexp(-((eNorm-80.0d0)/78.0d0)**2))
     &           *(1.0d0+(eNorm-80.0d0)/400.0d0)
      else
        lambdaW= (1.24d0-1.0d0/(1.0d0+dexp((eNorm-4.5d0)/2.9d0)))
     &           *(1.0d0+0.06d0*dexp(-((eNorm-14.0d0)/3.7d0 )**2))
     &           *(1.0d0-0.09d0*dexp(-((eNorm-80.0d0)/78.0d0)**2))
      endif

      lambdaV1 = 1.5d0 - 0.65d0/(1.0d0+dexp((eNorm-1.3d0)/3.0d0))

      lambdaW1 = (1.1d0+0.44d0/(1.0d0+(dexp((eNorm-40.0d0)/50.9d0))**4))
     &          *(1.0d0-0.065d0/dexp(((eNorm-40.0d0 )/13.0d0)**2))
     &          *(1.0d0-0.083d0/dexp(((eNorm-200.0d0)/80.0d0)**2))

      write(6,602) lambdaV, lambdaV1, lambdaW, lambdaW1
602   format("lambdaV, lambdaV1, lambdaW, lambdaW1=",/,4f8.3,/)

*     print'(a,f10.4)',' incident cm energy (MeV) =  ',E
*     ------------------------------------------------------------
*     print*,' potential at radii: rmin,rmax,rstep '
*     read*,rmin,rmax,rstep
*     ------------------------------------------------------------
      rmin=0.d0
      rmax=nrmax*rstep
!       rstep=step
   14 print*,' Uses the JLM parameterisation of Bauge '
*     ------------------------------------------------------------
      iset=1
*  11 print*,' Version of local density approximation '
*     print*,'   1) LDA (rx=rt)'
*     print*,'   2) LDA (rx=rp)'
*     print*,'   3) LDA (Mid-point) ******** '
!       ilda=3

      ijax=1000
      print*,' using read matter density '
      print*,' ---------------------------------------------------'
      write(6,601) densFileP, densFileT
  601 format("projectile and target densitie files: ", a, a)

! read projectile density file
      open(19,file='/Users/Fermi/dev/OMP/den/'//densFileP,status='old')
      print*
*     following for reading of Hartree-Fock densities
      rewind 19
      ico=0
      read(19,'(a)') guff
      read(19,'(a)') guff
      read(19,'(a)') guff
      do ijj=1,1000
        read(19,*,end=707) radP(ijj),rhoPp(ijj),rhoPn(ijj),rhoPm(ijj)
        ico=ico+1
      enddo
  707 continue
      close(19)

      ivalP=ico
      print*,' projectile density: number of read HF radii ',ivalP
      print*,' with step ',radP(2)-radP(1)

! read target density file
      open(19,file='/Users/Fermi/dev/OMP/den/'//densFileT,status='old')
      print*
*     following for reading of Hartree-Fock densities
      rewind 19
      ico=0
      read(19,'(a)') guff
      read(19,'(a)') guff
      read(19,'(a)') guff
      do ijj=1,1000
        read(19,*,end=708) radT(ijj),rhoTp(ijj),rhoTn(ijj),rhoTm(ijj)
        ico=ico+1
      enddo
  708 continue
      close(19)

      ivalT=ico
      print*,' target density: number of read HF radii ',ivalT
      print*,' with step ',radT(2)-radT(1)

*     ------------------------------------------------------------
*        do ijj=1,ival
*         write(30,*) rad(ijj),rhom(ijj)
*        enddo
*     ------------------------------------------------------------

      print*,' ---------------------------------------------------'

*     look up potential parameters
      call assign(iset)
*     ------------------------------------------------------------
*     print*,' Maximum NN relative separation (rptmax) for folding'
*     read*,rptmax
*     ------------------------------------------------------------
!       rptmax=4.d0
*     ------------------------------------------------------------
*     print9,rptmax
*     print*,' Quadrature points: radial and cos(theta) integrals'
*     read*,mqr,mqmu
*     ------------------------------------------------------------
!       mqr=32
!       mqmu=48
*     ------------------------------------------------------------
*     print*,mqr,mqmu
      zero=0.d0
      one=1.d0
*     for integration over radius of target density
      call gauss(zero,rptmax,mqr,xrt,wrt)
*     for integration over cos(theta)
      call gauss(-one,one,mqmu,xmu,wmu)
*     ------------------------------------------------------------
*     Gaussian effective interaction strength (for t=1.0 fm)
*     and for unit integrated strength
*     print*,' real and imaginary Gaussian folding ranges t'
*     read*,tr,ti
*     print9,tr,ti
*     ------------------------------------------------------------
!       tr=1.d0
!       ti=1.d0
*     ------------------------------------------------------------
      write(6,604) tr, ti
604   format("tr=", f7.4, ", ti=", f7.4)

      t2r=tr*tr
      t2i=ti*ti
      rmagr=1.d0/(dsqrt(pi)*tr)**3
      rmagi=1.d0/(dsqrt(pi)*ti)**3

*     ------------------------------------------------------------
!     n-A potential for interpolation

      rnAmax = rmax + 10.0d0
      i=0
      do rp=rstep,rnAmax,rstep
        i=i+1
        pApotR(i)=0.0d0
        PApotI(i)=0.0d0
        nApotR(i)=0.0d0
        nApotI(i)=0.0d0

        rp2=rp*rp

        nAR(i)=rp

        do imqr=1,mqr
          rt=xrt(imqr)
          rt2=rt*rt
          summPr=0.d0
          summPi=0.d0
          summNr=0.d0
          summNi=0.d0

          do imqmu=1,mqmu
            bval=rp*rt*xmu(imqmu)
            rpt2=rt2+rp2+2.d0*bval
            rpt=dsqrt(rpt2)
            gg3r=g3(rmagr,t2r,rpt2)*rt2
            gg3i=g3(rmagi,t2i,rpt2)*rt2

            if(ilda .eq. 1) then
              rx = rt
            elseif(ilda .eq. 2) then
              rx = rp
            elseif(ilda .eq. 3) then
              rx = dsqrt(rp2+rt2-2.0d0*bval)/2.0d0
            endif

            rhot=1.d-15
            if(rt.lt.radT(ivalT)) rhot=terp(rt,rhoTm,radT,ivalT,ijax)
!             write(30,'(1p,2e12.4)') rt, rhot

            rhox=1.d-15
            alpha = (nt-zt)/at
            if(rx.lt.radT(ivalT)) then
              rhoxn=terp(rx,rhoTn,radT,ivalT,ijax)
              rhoxp=terp(rx,rhoTp,radT,ivalT,ijax)
              rhox=rhoxn+rhoxp
              alpha = (rhoxn-rhoxp)/rhox
            endif

*       if proton take care of Coulomb interaction
!             Ecal=Ecal
            if(rx.ge.rc) then
              vc=1.44d0*zt/rx
            else
              vc=0.72d0*zt/rc*(3.d0-(rx/rc)**2)
            endif

            rmtildeP=1.0d0
            rmtildeN=1.0d0

            call pots(Ecal-vc,rhox,iset,V0P,W0P,V1P,W1P,rmtildeP)
            call pots(Ecal   ,rhox,iset,V0N,W0N,V1N,W1N,rmtildeN)

            summPr=summPr+gg3r*wmu(imqmu)*rhot*lambdaV
     &                       *(V0P-alpha*lambdaV1*V1P)/rhox

            summPi=summPi+gg3i*wmu(imqmu)*rhot*rmtildeP*lambdaW
     &                       *(W0P-alpha*lambdaW1*W1P)/rhox

            summNr=summNr+gg3r*wmu(imqmu)*rhot*lambdaV
     &                       *(V0N+alpha*lambdaV1*V1N)/rhox

            summNi=summNi+gg3i*wmu(imqmu)*rhot*rmtildeN*lambdaW
     &                       *(W0N+alpha*lambdaW1*W1N)/rhox
          enddo
          pApotR(i)=pApotR(i)+wrt(imqr)*summPr
          pApotI(i)=pApotI(i)+wrt(imqr)*summPi
          nApotR(i)=nApotR(i)+wrt(imqr)*summNr
          nApotI(i)=nApotI(i)+wrt(imqr)*summNi
        enddo
        pApotR(i)=2.d0*pi*pApotR(i)
        pApotI(i)=2.d0*pi*pApotI(i)
        nApotR(i)=2.d0*pi*nApotR(i)
        nApotI(i)=2.d0*pi*nApotI(i)
        write(35,113) rp, pApotR(i), pApotI(i), nApotR(i), nApotI(i)
        ajvp(i) = pApotR(i)*rp*rp
        ajwp(i) = pApotI(i)*rp*rp
        ajvn(i) = nApotR(i)*rp*rp
        ajwn(i) = nApotI(i)*rp*rp
        ivalnA=i
      enddo

c     calculation A-A potential by interpolation
      i=0
!       jv=0.0d0; jw=0.0d0

      do RAB = rstep, rmax+0.01d0, rstep
       i=i+1
c       write(6,*) "rab=", rab

       potr(i) = 0.0d0
       poti(i) = 0.0d0
       RABS = RAB*RAB

       do irp = 1, mqr
        r1 = xrt(irp)
        r1s = r1*r1

        sumr1r = 0.0d0
        sumr1i = 0.0d0
        do imuP = 1, mqmu
         bval1B = RAB*r1*xmu(imuP)
         r1BS = RABS + r1S - 2.0d0*bval1B
         r1B = dsqrt(r1BS)

         potPr1r = -1.0d-15
         potPr1i = -1.0d-15
         potNr1r = -1.0d-15
         potNr1i = -1.0d-15

         if(r1B .lt. rnAmax) then
          potPr1r = terp(r1B,pApotR,nAR,ivalNA,ijax)
          potPr1i = terp(r1B,pApotI,nAR,ivalNA,ijax)
          potNr1r = terp(r1B,nApotR,nAR,ivalNA,ijax)
          potNr1i = terp(r1B,nApotI,nAR,ivalNA,ijax)

!           write(36,112) r1B, potPr1r, potPr1i
         endif

c weight n+A potential with projectile density at r1
         rhoPr1=1.d-30
         rhoNr1=1.d-30
         if(r1.lt.radP(ivalP))then
          rhoPr1=terp(r1,rhoPp,radP,ivalP,ijax)
          rhoNr1=terp(r1,rhoPn,radP,ivalP,ijax)
         endif

         sumr1r = sumr1r + (rhoPr1*potPr1r+rhoNr1*potNr1r)*wmu(imuP)
         sumr1i = sumr1i + (rhoPr1*potPr1i+rhoNr1*potNr1i)*wmu(imuP)
        enddo

c  end of loop over r1 (irp)
        potr(i) = potr(i) + sumr1r*wrt(irp)*r1S
        poti(i) = poti(i) + sumr1i*wrt(irp)*r1S
       enddo

c  end of loop over RAB
        potr(i) = potr(i)*2.0d0*pi
        poti(i) = poti(i)*2.0d0*pi
        ajv(i) = potr(i)*rab*rab
        ajw(i) = poti(i)*rab*rab
        ajv4(i) = ajv(i)*rab*rab
        ajw4(i) = ajw(i)*rab*rab

      enddo

      call sim(ajv,jv,1,nrmax,rstep)
      call sim(ajw,jw,1,nrmax,rstep)
      call sim(ajv4,jv4,1,nrmax,rstep)
      call sim(ajw4,jw4,1,nrmax,rstep)

      rmsv=dsqrt(jv4/jv)
      rmsw=dsqrt(jw4/jw)

      call sim(ajvp,jvp,1,ivalNA,rstep)
      call sim(ajwp,jwp,1,ivalNA,rstep)
      call sim(ajvn,jvn,1,ivalNA,rstep)
      call sim(ajwn,jwn,1,ivalNA,rstep)

      Jv = 4.0d0*pi*Jv/ap/at
      Jw = 4.0d0*pi*Jw/ap/at
      jvp= 4.0d0*pi*Jvp/at
      jwp= 4.0d0*pi*Jwp/at
      jvn= 4.0d0*pi*Jvn/at
      jwn= 4.0d0*pi*Jwn/at

      write(6,605) Jv, Jw, jvp, jwp, jvn, jwn
605   format("Volume integrals: ", 1p, 6e14.6)

      write(6,606) rmsv, rmsw
606   format('rms radii Re and Im',1p,6e14.6)

c output for FRESCO and plot
      write(4,'(a)')  '# djlmb2 with systematic Nr and Ni'
      write(34,'(a)') '# JLM, r, real, imaginary'
      write(4,401) nrmax, rstep, rstep
401   format( I4, 2f8.3)

      do I=1,nrmax
        RAB = rstep*dfloat(I)
        write(4, 111)    Nr*potr(i), Ni*poti(i)
        write(34,112) rab, potr(i), poti(i)
      enddo

111   format(1p,     2(e16.7))
112   format(f8.3,1p,2(e16.7))
113   format(f8.3,1p,4(e16.7))

      end
