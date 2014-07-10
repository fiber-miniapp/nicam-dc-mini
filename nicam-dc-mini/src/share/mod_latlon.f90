!-------------------------------------------------------------------------------
!>
!! Geodesic (Lat-Lon) grid module
!!
!! @par Description
!!         This module contains the tools to convert between icosaheral grid
!!         and lat-lon grid
!!
!! @author S.Iga
!!
!! @par History
!! @li      2004-02-17 (S.Iga)    Imported from igdc-4.39
!! @li      2004-03-05 (S.Iga)    'mod_latlon2.f90' is merged into this module.
!! @li      2004-05-31 (H.Tomita) Delete debug write statements
!! @li      2005-11-10 (M.Satoh)  bug fix: output_lldata_type_in
!! @li      2005-12-17 (M.Satoh)  add namelist options for lat/lon max/min_deg
!! @li      2006-02-10 (S.Iga)    bug fix: for the case LL grid is near to
!! @li                            ICO grid (in the past, for gl11, weight at
!! @li                            ix=8197,iy=4176 was NaN)
!! @li      2007-07-12 (T.Mitsui) bug fix: "fid" had been undefined in mkllmap.
!! @li      2009-07-17 (Y.Yamada) bug fix: negative area had existed in mkllmap.
!! @li      2011-01-11 (S.Iga)    handling "lon>180"
!! @li      2011-11-09  H.Yashiro [mod] Avoid arc-cos, precise calculation
!!
!<
module mod_latlon
  !-----------------------------------------------------------------------------
  !
  !++ Used modules
  !
  use mpi
  use mod_adm, only: &
     ADM_LOG_FID, &
     ADM_NSYS,    &
     ADM_MAXFNAME
  !-----------------------------------------------------------------------------
  implicit none
  private
  !-----------------------------------------------------------------------------
  !
  !++ Public procedure
  !
!cx  public :: LATLON_ico_setup
!cx  public :: LATLON_setup

  !-----------------------------------------------------------------------------
  !
  !++ Public parameters & variables
  !
  !-----------------------------------------------------------------------------
  !
  !++ Private procedure
  !
!cx  private :: setup_latlon
!cx  private :: set_equidist_grid
!cx  private :: set_gaussian_grid
!cx  private :: mkrelmap_ico2ll

  !-----------------------------------------------------------------------------
  !
  !++ Private parameters & variables
  !
  integer, public, parameter :: GMTR_P_nmax_var = 2
  integer, public, parameter :: GMTR_P_LAT = 1
  integer, public, parameter :: GMTR_P_LON = 2

  real(8), public, allocatable, save :: GMTR_P_ll   (:,:,:,:)
  real(8), public, allocatable, save :: GMTR_P_ll_pl(:,:,:,:)

  character(len=ADM_NSYS),  public, save :: polygon_type = 'ON_SPHERE' ! triangle is fit to the sphere
  !                                                        'ON_PLANE'  ! triangle is treated as 2D

end module mod_latlon
!-------------------------------------------------------------------------------
