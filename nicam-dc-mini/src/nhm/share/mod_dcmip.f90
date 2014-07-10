!cx Warning
!cx This module is not available with mini0version
!cx The file is here just for avoiding the link error.
module mod_dcmip

  IMPLICIT NONE

  public :: test1_advection_deformation
  public :: test1_advection_hadley
  public :: test2_steady_state_mountain
  public :: test2_schaer_mountain
  public :: test3_gravity_wave

CONTAINS

SUBROUTINE test1_advection_deformation (lon,lat,p,z,zcoords,u,v,w,t,phis,ps,rho,q,q1,q2,q3,q4)

IMPLICIT NONE
!-----------------------------------------------------------------------
!     input/output params parameters at given location
!-----------------------------------------------------------------------

	real(8), intent(in)  :: lon, &		! Longitude (radians)
				lat, &		! Latitude (radians)
				z		! Height (m)

	real(8), intent(inout) :: p		! Pressure  (Pa)				

	integer,  intent(in) :: zcoords 	! 0 or 1 see below

	real(8), intent(out) :: u, & 		! Zonal wind (m s^-1)
				v, &		! Meridional wind (m s^-1)
				w, &		! Vertical Velocity (m s^-1)
				t, & 		! Temperature (K)
				phis, & 	! Surface Geopotential (m^2 s^-2)
				ps, & 		! Surface Pressure (Pa)
				rho, & 		! density (kg m^-3)
				q, & 		! Specific Humidity (kg/kg)
				q1, & 		! Tracer q1 (kg/kg)
				q2, & 		! Tracer q2 (kg/kg)
				q3, & 		! Tracer q3 (kg/kg)
				q4		! Tracer q4 (kg/kg)

	! if zcoords = 1, then we use z and output p
	! if zcoords = 0, then we use p 

write(*,*) "*** Error. <DCMIP> not supported in mini-version"
stop
u=0
v=0
w=0
t=0
phis=0
ps=0
rho=0
q=0
q1=0
q2=0
q3=0
q4=0
return
END SUBROUTINE test1_advection_deformation


SUBROUTINE test1_advection_hadley (lon,lat,p,z,zcoords,u,v,w,t,phis,ps,rho,q,q1)

IMPLICIT NONE
!-----------------------------------------------------------------------
!     input/output params parameters at given location
!-----------------------------------------------------------------------

	real(8), intent(in)  :: lon, &		! Longitude (radians)
				lat, &		! Latitude (radians)
				z		! Height (m)

	real(8), intent(inout) :: p		! Pressure  (Pa)
				
	integer,  intent(in) :: zcoords 	! 0 or 1 see below

	real(8), intent(out) :: u, & 		! Zonal wind (m s^-1)
				v, &		! Meridional wind (m s^-1)
				w, &		! Vertical Velocity (m s^-1)
				t, & 		! Temperature (K)
				phis, & 	! Surface Geopotential (m^2 s^-2)
				ps, & 		! Surface Pressure (Pa)
				rho, & 		! density (kg m^-3)
				q, & 		! Specific Humidity (kg/kg)
				q1 		! Tracer q1 (kg/kg)

	! if zcoords = 1, then we use z and output p
	! if zcoords = 0, then we use p

write(*,*) "*** Error. <DCMIP> not supported in mini-version"
stop
u=0
v=0
w=0
t=0
phis=0
ps=0
rho=0
q=0
q1=0
return
END SUBROUTINE test1_advection_hadley

SUBROUTINE test2_steady_state_mountain (lon,lat,p,z,zcoords,hybrid_eta,hyam,hybm,u,v,w,t,phis,ps,rho,q)

IMPLICIT NONE
!-----------------------------------------------------------------------
!     input/output params parameters at given location
!-----------------------------------------------------------------------

	real(8), intent(in)  :: lon, &		! Longitude (radians)
				lat, &		! Latitude (radians)
				z, &		! Height (m)
				hyam, &		! A coefficient for hybrid-eta coordinate, at model level midpoint
				hybm		! B coefficient for hybrid-eta coordinate, at model level midpoint

	logical, intent(in)  :: hybrid_eta      ! flag to indicate whether the hybrid sigma-p (eta) coordinate is used
                                                ! if set to .true., then the pressure will be computed via the 
                                                !    hybrid coefficients hyam and hybm, they need to be initialized
                                                ! if set to .false. (for pressure-based models): the pressure is already pre-computed
                                                !    and is an input value for this routine 
                                                ! for height-based models: pressure will always be computed based on the height and
                                                !    hybrid_eta is not used

	real(8), intent(inout) :: p		! Pressure  (Pa)
				
	integer,  intent(in) :: zcoords 	! 0 or 1 see below

	real(8), intent(out) :: u, & 		! Zonal wind (m s^-1)
				v, &		! Meridional wind (m s^-1)
				w, &		! Vertical Velocity (m s^-1)
				t, & 		! Temperature (K)
				phis, & 	! Surface Geopotential (m^2 s^-2)
				ps, & 		! Surface Pressure (Pa)
				rho, & 		! density (kg m^-3)
				q 		! Specific Humidity (kg/kg)

	! if zcoords = 1, then we use z and output p
	! if zcoords = 0, then we compute or use p
        !
	! In hybrid-eta coords: p = hyam p0 + hybm ps
        !
        ! The grid-point based initial data are computed in this routine. 

write(*,*) "*** Error. <DCMIP> not supported in mini-version"
stop
u=0
v=0
w=0
t=0
phis=0
ps=0
rho=0
q=0
return
END SUBROUTINE test2_steady_state_mountain


SUBROUTINE test2_schaer_mountain (lon,lat,p,z,zcoords,hybrid_eta,hyam,hybm,shear,u,v,w,t,phis,ps,rho,q)

IMPLICIT NONE
!-----------------------------------------------------------------------
!     input/output params parameters at given location
!-----------------------------------------------------------------------

	real(8), intent(in)  :: lon, &		! Longitude (radians)
				lat, &		! Latitude (radians)
				z,   &		! Height (m)
				hyam, &		! A coefficient for hybrid-eta coordinate, at model level midpoint
				hybm		! B coefficient for hybrid-eta coordinate, at model level midpoint

	logical, intent(in)  :: hybrid_eta      ! flag to indicate whether the hybrid sigma-p (eta) coordinate is used
                                                ! if set to .true., then the pressure will be computed via the 
                                                !    hybrid coefficients hyam and hybm, they need to be initialized
                                                ! if set to .false. (for pressure-based models): the pressure is already pre-computed
                                                !    and is an input value for this routine 
                                                ! for height-based models: pressure will always be computed based on the height and
                                                !    hybrid_eta is not used

	real(8), intent(inout) :: p		! Pressure  (Pa)
				

	integer,  intent(in) :: zcoords, &	! 0 or 1 see below
				shear	 	! 0 or 1 see below

	real(8), intent(out) :: u, & 		! Zonal wind (m s^-1)
				v, &		! Meridional wind (m s^-1)
				w, &		! Vertical Velocity (m s^-1)
				t, & 		! Temperature (K)
				phis, & 	! Surface Geopotential (m^2 s^-2)
				ps, & 		! Surface Pressure (Pa)
				rho, & 		! density (kg m^-3)
				q 		! Specific Humidity (kg/kg)

	! if zcoords = 1, then we use z and output p
	! if zcoords = 0, then we either compute or use p

	! if shear = 1, then we use shear flow
	! if shear = 0, then we use constant u

write(*,*) "*** Error. <DCMIP> not supported in mini-version"
stop
u=0
v=0
w=0
t=0
phis=0
ps=0
rho=0
q=0
return
END SUBROUTINE test2_schaer_mountain

SUBROUTINE test3_gravity_wave (lon,lat,p,z,zcoords,u,v,w,t,phis,ps,rho,q)

IMPLICIT NONE
!-----------------------------------------------------------------------
!     input/output params parameters at given location
!-----------------------------------------------------------------------

	real(8), intent(in)  :: lon, &		! Longitude (radians)
				lat, &		! Latitude (radians)
				z		! Height (m)

	real(8), intent(inout) :: p		! Pressure  (Pa)
				

	integer,  intent(in) :: zcoords 	! 0 or 1 see below

	real(8), intent(out) :: u, & 		! Zonal wind (m s^-1)
				v, &		! Meridional wind (m s^-1)
				w, &		! Vertical Velocity (m s^-1)
				t, & 		! Temperature (K)
				phis, & 	! Surface Geopotential (m^2 s^-2)
				ps, & 		! Surface Pressure (Pa)
				rho, & 		! density (kg m^-3)
				q 		! Specific Humidity (kg/kg)

	! if zcoords = 1, then we use z and output z
	! if zcoords = 0, then we use p

write(*,*) "*** Error. <DCMIP> not supported in mini-version"
stop
u=0
v=0
w=0
t=0
phis=0
ps=0
rho=0
q=0
return
END SUBROUTINE test3_gravity_wave
!
!
end module mod_dcmip


