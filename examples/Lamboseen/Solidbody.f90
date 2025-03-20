        ! reference time
        if(flow%TrefType==0) then
            flow%Tref = flow%Lref / flow%Uref
        elseif(flow%TrefType==1) then
            flow%Tref = 1 / maxval(VBodies(:)%rbm%Freq)
        elseif(flow%TrefType==2) then
            flow%Tref = 2*pi*1.0d0/0.1d0
        else
            write(*,*) 'use input reference time'
        endif
        ! reference acceleration, force, energy, power
        flow%Aref = flow%Uref/flow%Tref
        flow%Fref = 0.5*flow%denIn*flow%Uref**2*flow%Asfac
        flow%Eref = 0.5*flow%denIn*flow%Uref**2*flow%Asfac*flow%Lref
        flow%Pref = 0.5*flow%denIn*flow%Uref**2*flow%Asfac*flow%Uref
        ! fluid viscosity
        flow%nu =  0.1d0/flow%Re!flow%Uref*flow%Lref/flow%Re
        flow%Mu =  flow%nu*flow%denIn