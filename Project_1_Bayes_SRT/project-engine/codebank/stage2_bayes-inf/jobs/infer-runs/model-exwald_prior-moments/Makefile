
MATLABDIR ?= /apps/MATLAB/R2017a
NESTEDLIBDIR =/rds/general/user/dc1010/home/neuromechanisms-cognition/bayes-inf/MultiNest_v3.10
LAPACKLIB = -llapack
LIBSDIRS ?= -L$(NESTEDLIBDIR)
LIBS = -lnest3  $(LAPACKLIB) -lblas
FC = ifort
MPICC ?= mpicc
MPIF90 ?= mpif90
##FFLAGS = -c

execname=bayesfit-exwald-mom-sim250
OBJFILES = $(execname).o

all = $(execname)

%.o: %.c
	$(MPICC) -g -DMX_COMPAT_64   -D_GNU_SOURCE -DMATLAB_MEX_FILE  -I"$(MATLABDIR)/extern/include" -I"$(MATLABDIR)/simulink/include"  -fexceptions -fPIC -fno-omit-frame-pointer -pthread -O -DNDEBUG $(CFLAGS) -c $*.c

$(execname): $(OBJFILES)
	$(MPICC) $(FFLAGS) -o $(execname) $(OBJFILES) $(LIBSDIRS) $(LIBS)  -Wl,--no-undefined -Wl,-rpath-link,$(MATLABDIR)/bin/glnxa64    -L"$(MATLABDIR)/bin/glnxa64" -lmx -lmex -lmat -lm -lstdc++ -leng

clean:
	rm -f *.o *.mod

