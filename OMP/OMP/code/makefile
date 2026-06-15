# djlm
# JLM potential for nucleus-nucleus
# based on jlm code of Jeff. Tostevin
# by D.Y. Pang
#

FFLAGS = -O3 -g
#FFLAGS =
FC     = gfortran
F90C   = $(FC)
FORM   =

COMMON = assign.o fermi.o g3.o gauss.o pots.o setmgl.o terp.o sim.o

OBJ    =$(COMMON) djlmb.o

target: djlmb2 mkdjlmb2
	mv djlmb2 ~/dev/bin/
	mv mkdjlmb2 ~/dev/bin/

djlmb2: $(OBJ)
	$(FC) $(FFLAGS) -o djlmb2  $(OBJ)

mkdjlmb2: mkdjlmb.o
	$(FC) $(FFLAGS) -o mkdjlmb2 mkdjlmb.o

.f.o:
	$(FC) $(FORM) -c $(FFLAGS) $<

clean:
	\rm -f *.o *.mod

cleanall:
	\rm -f *.o *.mod
