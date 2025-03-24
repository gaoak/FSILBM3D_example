        SUBROUTINE initialise_flow()
            implicit none
            real(8):: xCoord,yCoord,zCoord
            integer:: x, y, z
            real(8):: gamma,a0,x0
            real(8):: r1,r2,theta1,theta2,v_theta1,v_theta2
            gamma = 0.1d0
            a0 = 0.1d0
            x0 = 0.5d0
            ! calculating initial flow velocity and the distribution function
            do  x = 1, this%xDim
                xCoord = this%xmin + this%dh * (x - 1);
            do  y = 1, this%yDim
                yCoord = this%ymin + this%dh * (y - 1);
            do  z = 1, this%zDim
                zCoord = this%zmin + this%dh * (z - 1);
                this%den(z,y,x) = flow%denIn
                r1 = dsqrt((xCoord-x0)**2+zCoord**2)
                theta1 = atan2(zCoord,xCoord-x0)
                r2 = dsqrt((xCoord+x0)**2+zCoord**2)
                theta2 = atan2(zCoord,xCoord+x0)
                if(r1.gt.0.0001)then
                    v_theta1 = (gamma/(2*pi*r1))*(1.0d0-exp(-r1**2/(a0**2)))
                else
                    v_theta1 = 0.0d0
                endif
                if(r2.gt.0.0001)then
                    v_theta2 = (-gamma/(2*pi*r2))*(1.0d0-exp(-r2**2/(a0**2)))
                else
                    v_theta2 = 0.0d0
                endif
                ! call evaluate_velocity(this%blktime,zCoord,yCoord,xCoord,flow%uvwIn(1:SpaceDim),this%uuu(z,y,x,1:SpaceDim),flow%shearRateIn(1:3))
                this%uuu(z,y,x,1) = -v_theta1*sin(theta1)+(-v_theta2*sin(theta2))+flow%uvwIn(1)
                this%uuu(z,y,x,2) = 0.0d0+flow%uvwIn(2)
                this%uuu(z,y,x,3) =  v_theta1*cos(theta1)+( v_theta2*cos(theta2))+flow%uvwIn(3)
                call calculate_distribution_funcion(this%den(z,y,x),this%uuu(z,y,x,1:SpaceDim),this%fIn(z,y,x,0:lbmDim))
            enddo
            enddo
            enddo
        END SUBROUTINE initialise_flow