        ! fluid viscosity
        ! gamma = 0.1d0
        flow%nu =  0.1d0/flow%Re!flow%Uref*flow%Lref/flow%Re
        flow%Mu =  flow%nu*flow%denIn
    END SUBROUTINE