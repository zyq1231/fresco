      program mkdjlm
c  prepare input file for djlm
      write(6,601)
601   format("&basicInfo ap=, zp=, at=, zt=, Elab=,
     & densFileP='', densFileT='' /",/,
     & "&calCtrl   rstep=0.05, nrmax=300, rptmax=20.0, mqr=32, mqmu=32,
     &  tr=1.25, ti=1.35, ilda=1 /",//,
     & "Note: Elab is total energy in MeV, not in MeV/nucleon",/)
      end
