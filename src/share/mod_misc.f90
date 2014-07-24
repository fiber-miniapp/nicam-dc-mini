!-------------------------------------------------------------------------------
!>
!! miscellaneous module
!!
!! @par Description
!!         This module contains miscellaneous subroutines.
!!
!! @author  H.Tomita
!!
!! @par History
!! @li      2004-02-17 (H.Tomita)  Imported from igdc-4.33
!! @li      2005-11-15 (M.Satoh)   [mod] MISC_make_idstr
!! @li      2006-02-12 (S.Iga)     add critical value in MISC_triangle_area for the case angle=0
!!                                 integer(4) -> integer  for 'second'
!! @li      2006-02-25 (S.Iga)     bugfix on 06-02-12
!! @li      2006-08-10 (W.Yanase)  bug(?)fix on 06-08-10
!! @li      2006-08-22 (Y.Niwa)    bug fix
!! @li      2009-07-17 (Y.Yamada)  Add func[MISC_triangle_area_q].
!! @li      2011-11-11 (H.Yashiro) [Add] vector calculation suite
!!
!<
module mod_misc
  !-----------------------------------------------------------------------------
  implicit none
  private
  !-----------------------------------------------------------------------------
  !
  !++ Public parameters, variables & subroutines
  !
  public :: MISC_make_idstr        !--- make file name with a number
  public :: MISC_get_available_fid !--- get an available file ID
  public :: MISC_get_fid           !--- get an information of open or not
  public :: MISC_get_latlon        !--- calculate (lat,lon) from (x,y,z)
  public :: MISC_triangle_area     !--- calculate triangle area.
  public :: MISC_triangle_area_q   !--- calculate triangle area at quad precision.  ![Add] Y.Yamada 09/07/17
  public :: MISC_mk_gmtrvec        !--- calculate normal and tangential vecs.
  public :: MISC_msg_nmerror       !--- output error message
  ![Add] H.Yashiro 11/11/11
  public :: MISC_3dvec_cross         !--- calc exterior product for 3D vector
  public :: MISC_3dvec_dot           !--- calc interior product for 3D vector
  public :: MISC_3dvec_abs           !--- calc absolute value for 3D vector
  public :: MISC_3dvec_angle         !--- calc angle for 3D vector
  public :: MISC_3dvec_intersec      !--- calc intersection of two 3D vectors
  public :: MISC_3dvec_anticlockwise !--- sort 3D vectors anticlockwise
  public :: MISC_3Dvec_triangle      !--- calc triangle area on sphere, more precise
  public :: MISC_get_cartesian       !--- calc (x,y,z) from (lat,lon)
  public :: MISC_get_distance        !--- calc horizontal distance on the sphere

  !-----------------------------------------------------------------------------
  !
  !++ Private parameters, variables & subroutines
  !
  !--- minimum available fid
  integer, parameter, private :: min_fid = 7
  !
  !--- maximum available fid.
  integer, parameter, private :: max_fid = 99

  !--- number of separated file starts from 0 ?
  logical, private, parameter :: NSTR_ZERO_START = .true.

  !--- digit of separated file
  integer, private, save      :: NSTR_MAX_DIGIT  = 5
  !
  !<----  if running on ES, 
  !<----      NSTR_ZERO_START = .TRUE.
  !<----      NSTR_MAX_DIGIT  = 5
  !-----------------------------------------------------------------------------
contains
  !-----------------------------------------------------------------------------
  !>
  !> Description of the subroutine MISC_make_idstr
  !>
  subroutine MISC_make_idstr( &
       str,     & !--- [OUT]
       prefix,  & !--- [IN]
       ext,     & !--- [IN]
       numID,   & !--- [IN]
       digit    ) !--- [IN]
    implicit none

    character(len=*), intent(out) :: str    ! combined string (file name)
    character(len=*), intent(in)  :: prefix ! prefix
    character(len=*), intent(in)  :: ext    ! extention( e.g. .rgn ) 
    integer,          intent(in)  :: numID  ! number

    integer, optional, intent(in) :: digit  ! digit

    character(len=128) :: rankstr
    integer            :: setdigit
    !---------------------------------------------------------------------------

    if ( NSTR_ZERO_START ) then
       write(rankstr,'(I128.128)') numID-1
    else
       write(rankstr,'(I128.128)') numID
    endif

    if ( present(digit) ) then
       setdigit = digit
    else
       setdigit = NSTR_MAX_DIGIT
    endif

    rankstr(1:setdigit) = rankstr(128-(setdigit-1):128)
    rankstr(setdigit+1:128) = ' '

    str = trim(prefix)//'.'//trim(ext)//trim(rankstr) ! -> prefix.ext00000

    return
  end subroutine MISC_make_idstr

  !-----------------------------------------------------------------------------
  !>
  !> Description of the function %NAME
  !> @return
  !>
  function MISC_get_available_fid()  &
       result(fid)                     !--- file id
    !
    implicit none
    !
    integer :: fid
    logical :: i_opened
    !
    do fid = min_fid,max_fid
       INQUIRE (fid, OPENED=I_OPENED)
       if(.not.I_OPENED) return
    enddo
    !
  end function MISC_get_available_fid

  !-----------------------------------------------------------------------------
  !>
  !> Description of the function %NAME
  !> @return
  !>
  function MISC_get_fid( fname )  &
       result(fid)                   !--- file ID
    !
    implicit none
    !
    character(*), intent(in) :: fname
    !
    integer :: fid
    logical :: i_opened
    !
    INQUIRE (FILE=trim(fname), OPENED=i_opened, NUMBER=fid)
    if(.not.i_opened) fid = -1
    !
  end function MISC_get_fid

  !-----------------------------------------------------------------------------
  !>
  !> Description of the subroutine MISC_get_latlon
  !>
  subroutine MISC_get_latlon( &
       lat, lon,              & !--- INOUT : latitude and longitude
       x, y, z )                !--- IN : Cartesian coordinate ( on the sphere )
    !
    implicit none
    !
    real(8),intent(inout) :: lat, lon
    real(8),intent(in) :: x,y,z
    !
    real(8), parameter :: epsilon = 1.0D-99
    real(8) :: leng,leng_xy
    !
    leng=sqrt(x*x+y*y+z*z)
    !
    ! --- vector length equals to zero.
    if(leng<epsilon) then
       lat=0.0D0
       lon=0.0D0
       return
    endif
    ! --- vector is parallele to z axis.
    if(z/leng>=1.0D0) then
       lat=asin(1.0D0)
       lon=0.0D0
       return
    elseif(z/leng<=-1.0D0) then
       lat=asin(-1.0D0)
       lon=0.0D0
       return
    endif
    ! --- not parallele to z axis
    lat=asin(z/leng)
    !
    leng_xy=sqrt(x*x+y*y)
    if(leng_xy<epsilon) then
       lon=0.0D0
       return
    endif
    if(x/leng_xy>=1.0D0) then
       lon=acos(1.0D0)
       if(y<0.0D0) lon=-lon
       return
    elseif(x/leng_xy<=-1.0D0) then
       lon=acos(-1.0D0)
       if(y<0.0D0) lon=-lon
       return
    endif
    lon=acos(x/leng_xy)
    if(y<0.0D0) lon=-lon
    return
  end subroutine MISC_get_latlon

  !-----------------------------------------------------------------------------
  !>
  !> Description of the function %NAME
  !> @return
  !>
  function MISC_triangle_area( &
       a, b, c,                & !--- IN : three points vectors on a sphere.
       polygon_type,           & !--- IN : sphere triangle or plane one?
       radius,                 & !--- IN : radius
       critical)               & !--- IN : critical value to handle the case
                                 !         of ang=0 (optional) S.Iga060209
       result( area )            !--- OUT : triangle area
    !
    implicit none
    !
    integer, parameter :: ix = 1
    integer, parameter :: iy = 2
    integer, parameter :: iz = 3
    real(8), parameter :: pi  = 3.14159265358979323846D0
    !
    real(8) :: area
    real(8),intent(in) :: a(ix:iz),b(ix:iz),c(ix:iz)
    character(len=*), intent(in) :: polygon_type
    real(8) :: radius
    !
    !
    real(8) :: v01(ix:iz)
    real(8) :: v02(ix:iz)
    real(8) :: v03(ix:iz)
    !
    real(8) :: v11(ix:iz)
    real(8) :: v12(ix:iz)
    real(8) :: v13(ix:iz)
    !
    real(8) :: v21(ix:iz)
    real(8) :: v22(ix:iz)
    real(8) :: v23(ix:iz)
    real(8) :: w21(ix:iz)
    real(8) :: w22(ix:iz)
    real(8) :: w23(ix:iz)
    real(8) :: w11(ix:iz)
    real(8) :: w12(ix:iz)
    real(8) :: w13(ix:iz)

    real(8) :: v1(ix:iz)
    real(8) :: v2(ix:iz)
    real(8) :: w(ix:iz)
    !
    real(8) :: fac11,fac12,fac13
    real(8) :: fac21,fac22,fac23
    !
    real(8) :: r_v01_x_v01,r_v02_x_v02,r_v03_x_v03
    !
    real(8) :: ang(3)
    real(8) :: len
    !
    ! S.Iga060209=>
    real(8), optional:: critical
    ! S.Iga060209>=
    real(8):: epsi


    ! S.Iga060209=>
    if (.not.present(critical)) then
       !       critical = 0 !1d-10e
       epsi = 0.D0 !1d-10e
    else
       epsi=critical  !060224
    endif
    ! S.Iga060209>=


    !
    if(trim(polygon_type)=='ON_PLANE') then
       !
       !---- Note : On a plane,
       !----        area = | ourter product of two vectors |.
       v1(ix:iz)=b(ix:iz)-a(ix:iz)
       v2(ix:iz)=c(ix:iz)-a(ix:iz)
       !----
       w(ix) = v1(iy)*v2(iz)-v2(iy)*v1(iz)
       w(iy) = v1(iz)*v2(ix)-v2(iz)*v1(ix)
       w(iz) = v1(ix)*v2(iy)-v2(ix)*v1(iy)
       !
       area=0.5D0*sqrt(w(ix)*w(ix)+w(iy)*w(iy)+w(iz)*w(iz))
       !
       len = sqrt(a(ix)*a(ix)+a(iy)*a(iy)+a(iz)*a(iz))
       area=area*(radius/len)*(radius/len)
       !
       return
    elseif(trim(polygon_type)=='ON_SPHERE') then
       !
       !---- NOTE : On a unit sphere,
       !----        area = sum of angles - pi.
       v01(ix:iz)=a(ix:iz)
       v11(ix:iz)=b(ix:iz)-a(ix:iz)
       v21(ix:iz)=c(ix:iz)-a(ix:iz)
       !----
       v02(ix:iz)=b(ix:iz)
       v12(ix:iz)=a(ix:iz)-b(ix:iz)
       v22(ix:iz)=c(ix:iz)-b(ix:iz)
       !----
       v03(ix:iz)=c(ix:iz)
       v13(ix:iz)=a(ix:iz)-c(ix:iz)
       v23(ix:iz)=b(ix:iz)-c(ix:iz)
       !----
       r_v01_x_v01&
            =1.0D0/(v01(ix)*v01(ix)+v01(iy)*v01(iy)+v01(iz)*v01(iz))
       fac11=(v01(ix)*v11(ix)+v01(iy)*v11(iy)+v01(iz)*v11(iz))&
            *r_v01_x_v01
       fac21=(v01(ix)*v21(ix)+v01(iy)*v21(iy)+v01(iz)*v21(iz))&
            *r_v01_x_v01
       !---- Escape for the case arg=0 (S.Iga060209)
       area = 0.D0
       if ((v12(ix)**2+v12(iy)**2+v12(iz)**2) * r_v01_x_v01 <= epsi**2 ) return
       if ((v13(ix)**2+v13(iy)**2+v13(iz)**2) * r_v01_x_v01 <= epsi**2 ) return
       if ((v23(ix)**2+v23(iy)**2+v23(iz)**2) * r_v01_x_v01 <= epsi**2 ) return

       !----       !
       w11(ix)=v11(ix)-fac11*v01(ix)
       w11(iy)=v11(iy)-fac11*v01(iy)
       w11(iz)=v11(iz)-fac11*v01(iz)
       !
       w21(ix)=v21(ix)-fac21*v01(ix)
       w21(iy)=v21(iy)-fac21*v01(iy)
       w21(iz)=v21(iz)-fac21*v01(iz)
       !
       ang(1)=(w11(ix)*w21(ix)+w11(iy)*w21(iy)+w11(iz)*w21(iz))&
            /( sqrt(w11(ix)*w11(ix)+w11(iy)*w11(iy)+w11(iz)*w11(iz))&
            * sqrt(w21(ix)*w21(ix)+w21(iy)*w21(iy)+w21(iz)*w21(iz)) )
       if(ang(1)>1.0D0) ang(1) = 1.0D0
       if(ang(1)<-1.0D0) ang(1) = -1.0D0
       ang(1)=acos(ang(1))
       !
       r_v02_x_v02&
            =1.0D0/(v02(ix)*v02(ix)+v02(iy)*v02(iy)+v02(iz)*v02(iz))
       fac12=(v02(ix)*v12(ix)+v02(iy)*v12(iy)+v02(iz)*v12(iz))&
            *r_v02_x_v02
       fac22=(v02(ix)*v22(ix)+v02(iy)*v22(iy)+v02(iz)*v22(iz))&
            *r_v02_x_v02
       !
       w12(ix)=v12(ix)-fac12*v02(ix)
       w12(iy)=v12(iy)-fac12*v02(iy)
       w12(iz)=v12(iz)-fac12*v02(iz)
       !
       w22(ix)=v22(ix)-fac22*v02(ix)
       w22(iy)=v22(iy)-fac22*v02(iy)
       w22(iz)=v22(iz)-fac22*v02(iz)
       !
       ang(2)=(w12(ix)*w22(ix)+w12(iy)*w22(iy)+w12(iz)*w22(iz))&
            /( sqrt(w12(ix)*w12(ix)+w12(iy)*w12(iy)+w12(iz)*w12(iz))&
            *sqrt(w22(ix)*w22(ix)+w22(iy)*w22(iy)+w22(iz)*w22(iz)) )
       if(ang(2)>1.0D0) ang(2) = 1.0D0
       if(ang(2)<-1.0D0) ang(2) = -1.0D0
       ang(2)=acos(ang(2))
       !
       r_v03_x_v03&
            =1.0D0/(v03(ix)*v03(ix)+v03(iy)*v03(iy)+v03(iz)*v03(iz))
       fac13=(v03(ix)*v13(ix)+v03(iy)*v13(iy)+v03(iz)*v13(iz))&
            *r_v03_x_v03
       fac23=(v03(ix)*v23(ix)+v03(iy)*v23(iy)+v03(iz)*v23(iz))&
            *r_v03_x_v03
       !
       w13(ix)=v13(ix)-fac13*v03(ix)
       w13(iy)=v13(iy)-fac13*v03(iy)
       w13(iz)=v13(iz)-fac13*v03(iz)
       !
       w23(ix)=v23(ix)-fac23*v03(ix)
       w23(iy)=v23(iy)-fac23*v03(iy)
       w23(iz)=v23(iz)-fac23*v03(iz)
       !
       ang(3)=(w13(ix)*w23(ix)+w13(iy)*w23(iy)+w13(iz)*w23(iz))&
            /( sqrt(w13(ix)*w13(ix)+w13(iy)*w13(iy)+w13(iz)*w13(iz))&
            *sqrt(w23(ix)*w23(ix)+w23(iy)*w23(iy)+w23(iz)*w23(iz)) )
       if(ang(3)>1.0D0) ang(3) = 1.0D0
       if(ang(3)<-1.0D0) ang(3) = -1.0D0
       ang(3)=acos(ang(3))
       !----
       area=(ang(1)+ang(2)+ang(3)-pi)*radius*radius
       !
       return
       !
    endif
    !
  end function MISC_triangle_area

  !-----------------------------------------------------------------------------
  !>
  !> Description of the function %NAME
  !> @return
  !>
  function MISC_triangle_area_q( &
       a, b, c,                & !--- IN : three points vectors on a sphere.
       polygon_type,           & !--- IN : sphere triangle or plane one?
       radius,                 & !--- IN : radius
       critical)               & !--- IN : critical value to handle the case
                                 !         of ang=0 (optional) S.Iga060209
       result( area )            !--- OUT : triangle area
    !
    implicit none
    !
    integer, parameter :: ix = 1
    integer, parameter :: iy = 2
    integer, parameter :: iz = 3
    real(8), parameter :: pi  = 3.14159265358979323846E0_8
    !
    real(8) :: area
    real(8),intent(in) :: a(ix:iz),b(ix:iz),c(ix:iz)
    character(len=*), intent(in) :: polygon_type
    real(8) :: radius
    !
    !
    real(8) :: v01(ix:iz)
    real(8) :: v02(ix:iz)
    real(8) :: v03(ix:iz)
    !
    real(8) :: v11(ix:iz)
    real(8) :: v12(ix:iz)
    real(8) :: v13(ix:iz)
    !
    real(8) :: v21(ix:iz)
    real(8) :: v22(ix:iz)
    real(8) :: v23(ix:iz)
    real(8) :: w21(ix:iz)
    real(8) :: w22(ix:iz)
    real(8) :: w23(ix:iz)
    real(8) :: w11(ix:iz)
    real(8) :: w12(ix:iz)
    real(8) :: w13(ix:iz)

    real(8) :: v1(ix:iz)
    real(8) :: v2(ix:iz)
    real(8) :: w(ix:iz)
    !
    real(8) :: fac11,fac12,fac13
    real(8) :: fac21,fac22,fac23
    !
    real(8) :: r_v01_x_v01,r_v02_x_v02,r_v03_x_v03
    !
    real(8) :: ang(3)
    real(8) :: len
    real(8) :: a16(3)
    real(8) :: area16

    real(8), optional:: critical
    real(8):: epsi


    if ( .not. present(critical)) then
       epsi = 0.E0_8
    else
       epsi = real(critical,kind=8)
    endif

    if(trim(polygon_type)=='ON_PLANE') then
       !---- Note : On a plane,
       !----        area = | ourter product of two vectors |.
       v1(ix:iz)= real(b(ix:iz),kind=8) - real(a(ix:iz),kind=8)
       v2(ix:iz)= real(c(ix:iz),kind=8) - real(a(ix:iz),kind=8)

       w(ix) = v1(iy)*v2(iz)-v2(iy)*v1(iz)
       w(iy) = v1(iz)*v2(ix)-v2(iz)*v1(ix)
       w(iz) = v1(ix)*v2(iy)-v2(ix)*v1(iy)

       area16 = 0.5E0_8 * sqrt(w(ix)*w(ix)+w(iy)*w(iy)+w(iz)*w(iz))

       a16(ix:iz) = real(a(ix:iz),kind=8)
       len = sqrt( a16(ix)*a16(ix)+a16(iy)*a16(iy)+a16(iz)*a16(iz) )
       area16 = area16 * (radius/len)*(radius/len)

       area = real(area16,kind=8)

       return
    elseif(trim(polygon_type)=='ON_SPHERE') then
       !
       !---- NOTE : On a unit sphere,
       !----        area = sum of angles - pi.
       v01(ix:iz)=real(a(ix:iz),kind=8)
       v11(ix:iz)=real(b(ix:iz),kind=8)-real(a(ix:iz),kind=8)
       v21(ix:iz)=real(c(ix:iz),kind=8)-real(a(ix:iz),kind=8)
       !----
       v02(ix:iz)=real(b(ix:iz),kind=8)
       v12(ix:iz)=real(a(ix:iz),kind=8)-real(b(ix:iz),kind=8)
       v22(ix:iz)=real(c(ix:iz),kind=8)-real(b(ix:iz),kind=8)
       !----
       v03(ix:iz)=real(c(ix:iz),kind=8)
       v13(ix:iz)=real(a(ix:iz),kind=8)-real(c(ix:iz),kind=8)
       v23(ix:iz)=real(b(ix:iz),kind=8)-real(c(ix:iz),kind=8)
       !----
       r_v01_x_v01&
            =1.0D0/(v01(ix)*v01(ix)+v01(iy)*v01(iy)+v01(iz)*v01(iz))
       fac11=(v01(ix)*v11(ix)+v01(iy)*v11(iy)+v01(iz)*v11(iz))&
            *r_v01_x_v01
       fac21=(v01(ix)*v21(ix)+v01(iy)*v21(iy)+v01(iz)*v21(iz))&
            *r_v01_x_v01
       !---- Escape for the case arg=0 (S.Iga060209)
       area=0E0_8

       if ((v12(ix)**2+v12(iy)**2+v12(iz)**2) * r_v01_x_v01 <= epsi**2 ) return
       if ((v13(ix)**2+v13(iy)**2+v13(iz)**2) * r_v01_x_v01 <= epsi**2 ) return
       if ((v23(ix)**2+v23(iy)**2+v23(iz)**2) * r_v01_x_v01 <= epsi**2 ) return

       !----       !
       w11(ix)=v11(ix)-fac11*v01(ix)
       w11(iy)=v11(iy)-fac11*v01(iy)
       w11(iz)=v11(iz)-fac11*v01(iz)
       !
       w21(ix)=v21(ix)-fac21*v01(ix)
       w21(iy)=v21(iy)-fac21*v01(iy)
       w21(iz)=v21(iz)-fac21*v01(iz)
       !
       ang(1)=(w11(ix)*w21(ix)+w11(iy)*w21(iy)+w11(iz)*w21(iz))&
            /( sqrt(w11(ix)*w11(ix)+w11(iy)*w11(iy)+w11(iz)*w11(iz))&
            * sqrt(w21(ix)*w21(ix)+w21(iy)*w21(iy)+w21(iz)*w21(iz)) )
       if( ang(1) >  1.0E0_8 ) ang(1) =  1.E0_8
       if( ang(1) <- 1.0E0_8 ) ang(1) = -1.E0_8
       ang(1)=acos(ang(1))
       !
       r_v02_x_v02&
            =1.0D0/(v02(ix)*v02(ix)+v02(iy)*v02(iy)+v02(iz)*v02(iz))
       fac12=(v02(ix)*v12(ix)+v02(iy)*v12(iy)+v02(iz)*v12(iz))&
            *r_v02_x_v02
       fac22=(v02(ix)*v22(ix)+v02(iy)*v22(iy)+v02(iz)*v22(iz))&
            *r_v02_x_v02
       !
       w12(ix)=v12(ix)-fac12*v02(ix)
       w12(iy)=v12(iy)-fac12*v02(iy)
       w12(iz)=v12(iz)-fac12*v02(iz)
       !
       w22(ix)=v22(ix)-fac22*v02(ix)
       w22(iy)=v22(iy)-fac22*v02(iy)
       w22(iz)=v22(iz)-fac22*v02(iz)
       !
       ang(2)=(w12(ix)*w22(ix)+w12(iy)*w22(iy)+w12(iz)*w22(iz))&
            /( sqrt(w12(ix)*w12(ix)+w12(iy)*w12(iy)+w12(iz)*w12(iz))&
            *sqrt(w22(ix)*w22(ix)+w22(iy)*w22(iy)+w22(iz)*w22(iz)) )

       if( ang(2) >  1.0E0_8 ) ang(2) =  1.E0_8
       if( ang(2) <- 1.0E0_8 ) ang(2) = -1.E0_8

       ang(2)=acos(ang(2))

       r_v03_x_v03&
            =1.0D0/(v03(ix)*v03(ix)+v03(iy)*v03(iy)+v03(iz)*v03(iz))
       fac13=(v03(ix)*v13(ix)+v03(iy)*v13(iy)+v03(iz)*v13(iz))&
            *r_v03_x_v03
       fac23=(v03(ix)*v23(ix)+v03(iy)*v23(iy)+v03(iz)*v23(iz))&
            *r_v03_x_v03
       !
       w13(ix)=v13(ix)-fac13*v03(ix)
       w13(iy)=v13(iy)-fac13*v03(iy)
       w13(iz)=v13(iz)-fac13*v03(iz)
       !
       w23(ix)=v23(ix)-fac23*v03(ix)
       w23(iy)=v23(iy)-fac23*v03(iy)
       w23(iz)=v23(iz)-fac23*v03(iz)
       !
       ang(3)=(w13(ix)*w23(ix)+w13(iy)*w23(iy)+w13(iz)*w23(iz))&
            /( sqrt(w13(ix)*w13(ix)+w13(iy)*w13(iy)+w13(iz)*w13(iz))&
            *sqrt(w23(ix)*w23(ix)+w23(iy)*w23(iy)+w23(iz)*w23(iz)) )

       if( ang(3) >  1.0E0_8 ) ang(3) =  1.E0_8
       if( ang(3) <- 1.0E0_8 ) ang(3) = -1.E0_8

       ang(3)=acos(ang(3))
       !----
       area16=(ang(1)+ang(2)+ang(3)-pi)*radius*radius

       area = real(area16,kind=8)

       return
    endif

  end function MISC_triangle_area_q

  !-----------------------------------------------------------------------------
  !>
  !> Description of the subroutine MISC_mk_gmtrvec
  !>
  subroutine MISC_mk_gmtrvec( &
       vs, ve,                & !--- IN : vectors at the start and the end
       tv,                    & !--- INOUT : tangential vector
       nv,                    & !--- INOUT : normal vector
       polygon_type,          & !--- IN : polygon type
       radius )                 !--- IN : radius
    !
    implicit none
    !
    integer, parameter :: ix = 1
    integer, parameter :: iy = 2
    integer, parameter :: iz = 3
    !
    real(8),intent(in) :: vs(ix:iz)
    real(8),intent(in) :: ve(ix:iz)
    real(8),intent(inout) :: tv(ix:iz)
    real(8),intent(inout) :: nv(ix:iz)
    character(len=*), intent(in) :: polygon_type
    real(8), intent(in) :: radius
    real(8) :: vec_len
    !
    real(8) :: len
    real(8) :: fact_nv,fact_tv
    !
    if(trim(polygon_type)=='ON_SPHERE') then
       !
       !--- NOTE : Length of a geodesic line is caluclatd
       !---        by (angle X radius).
       vec_len = sqrt(vs(ix)*vs(ix)+vs(iy)*vs(iy)+vs(iz)*vs(iz))
       if(vec_len/=0.0D0) then
          len=acos((vs(ix)*ve(ix)+vs(iy)*ve(iy)+vs(iz)*ve(iz))/vec_len/vec_len)&
               *radius
       else
          len = 0.0D0
       endif
       !
    elseif(trim(polygon_type)=='ON_PLANE') then
       !
       !--- NOTE : Length of a line
       len=sqrt(&
            +(vs(ix)-ve(ix))*(vs(ix)-ve(ix))&
            +(vs(iy)-ve(iy))*(vs(iy)-ve(iy))&
            +(vs(iz)-ve(iz))*(vs(iz)-ve(iz))&
            )
    endif
    !
    !
    !--- calculate normal and tangential vecors
    nv(ix)=vs(iy)*ve(iz)-vs(iz)*ve(iy)
    nv(iy)=vs(iz)*ve(ix)-vs(ix)*ve(iz)
    nv(iz)=vs(ix)*ve(iy)-vs(iy)*ve(ix)
    tv(ix)=ve(ix)-vs(ix)
    tv(iy)=ve(iy)-vs(iy)
    tv(iz)=ve(iz)-vs(iz)
    !
    !--- scaling to radius ( normal vector )
    fact_nv=len/sqrt(nv(ix)*nv(ix)+nv(iy)*nv(iy)+nv(iz)*nv(iz))
    nv(ix)=nv(ix)*fact_nv
    nv(iy)=nv(iy)*fact_nv
    nv(iz)=nv(iz)*fact_nv
    !
    !--- scaling to radius ( tangential vector )
    fact_tv=len/sqrt(tv(ix)*tv(ix)+tv(iy)*tv(iy)+tv(iz)*tv(iz))
    tv(ix)=tv(ix)*fact_tv
    tv(iy)=tv(iy)*fact_tv
    tv(iz)=tv(iz)*fact_tv
    !
    return
    !
  end subroutine MISC_mk_gmtrvec

  !-----------------------------------------------------------------------------
  !>
  !> Description of the subroutine MISC_msg_nmerror
  !>
  subroutine MISC_msg_nmerror( &
       ierr,                 & !--- IN : error id
       fid,                  & !--- IN : file id
       namelist_name,        & !--- IN : namelist name
       sub_name,             & !--- IN : subroutine name
       mod_name              & !--- IN : module name
       )
    implicit none
    integer, intent(in) ::  ierr
    integer, intent(in) ::  fid
    character(len=*) :: namelist_name
    character(len=*) :: sub_name
    character(len=*) :: mod_name
    if(ierr<0) then
       write(fid,*) &
            'Msg : Sub[',trim(sub_name),']/Mod[',trim(mod_name),']'
       write(fid,*) &
            ' *** Not found namelist. ',trim(namelist_name)
       write(fid,*) &
            ' *** Use default values.'
    elseif(ierr>0) then !--- fatal error
       write(*,*) &
            'Msg : Sub[',trim(sub_name),']/Mod[',trim(mod_name),']'
       write(*,*) &
            ' *** WARNING : Not appropriate names in namelist!! ',&
            trim(namelist_name),' CHECK!!'
    endif
  end subroutine MISC_msg_nmerror

  !-----------------------------------------------------------------------------
  subroutine MISC_3dvec_cross( nv, a, b, c, d )
    ! exterior product of vector a->b and c->d
    implicit none

    real(8), intent(out) :: nv(3)                  ! normal vector
    real(8), intent(in ) :: a(3), b(3), c(3), d(3) ! x,y,z(cartesian)
    !---------------------------------------------------------------------------

    nv(1) = ( b(2)-a(2) ) * ( d(3)-c(3) ) &
          - ( b(3)-a(3) ) * ( d(2)-c(2) )
    nv(2) = ( b(3)-a(3) ) * ( d(1)-c(1) ) &
          - ( b(1)-a(1) ) * ( d(3)-c(3) )
    nv(3) = ( b(1)-a(1) ) * ( d(2)-c(2) ) &
          - ( b(2)-a(2) ) * ( d(1)-c(1) )

    return
  end subroutine MISC_3dvec_cross

  !-----------------------------------------------------------------------------
  subroutine MISC_3dvec_dot( l, a, b, c, d )
    ! interior product of vector a->b and c->d
    implicit none

    real(8), intent(out) :: l
    real(8), intent(in ) :: a(3), b(3), c(3), d(3) ! x,y,z(cartesian)
    !---------------------------------------------------------------------------
    ! if a=c=zero-vector and b=d, result is abs|a|^2

    l = ( b(1)-a(1) ) * ( d(1)-c(1) ) &
      + ( b(2)-a(2) ) * ( d(2)-c(2) ) &
      + ( b(3)-a(3) ) * ( d(3)-c(3) ) 

    return
  end subroutine MISC_3dvec_dot

  !-----------------------------------------------------------------------------
  subroutine MISC_3dvec_abs( l, a )
    ! length of vector o->a
    implicit none

    real(8), intent(out) :: l
    real(8), intent(in ) :: a(3) ! x,y,z(cartesian)
    !---------------------------------------------------------------------------

    l = a(1)*a(1) + a(2)*a(2) + a(3)*a(3)
    l = sqrt(l)

    return
  end subroutine MISC_3dvec_abs

  !---------------------------------------------------------------------
  subroutine MISC_3dvec_angle( angle, a, b, c )
    ! calc angle between two vector(b->a,b->c)
    implicit none

    real(8), intent(out) :: angle
    real(8), intent(in ) :: a(3), b(3), c(3)

    real(8) :: nv(3), nvlenS, nvlenC
    !---------------------------------------------------------------------

    call MISC_3dvec_dot  ( nvlenC, b, a, b, c )
    call MISC_3dvec_cross( nv(:),  b, a, b, c )
    call MISC_3dvec_abs  ( nvlenS, nv(:) )
    angle = atan2( nvlenS, nvlenC )

    return
  end subroutine MISC_3dvec_angle

  !-----------------------------------------------------------------------------
  function MISC_3Dvec_triangle( &
       a, b, c,      & !--- IN : three point vectors on a sphere.
       polygon_type, & !--- IN : sphere triangle or plane one?
       radius      ) & !--- IN : radius
       result(area)    !--- OUT : triangle area
    implicit none

    real(8) :: area
    real(8),          intent( in) :: a(3), b(3), c(3)
    character(len=*), intent( in) :: polygon_type
    real(8),          intent( in) :: radius

    real(8), parameter :: o(3) = 0.D0

    ! ON_PLANE
    real(8) :: abc(3)
    real(8) :: prd, r

    ! ON_SPHERE
    real(8) :: angle(3)
    real(8) :: oaob(3), oaoc(3)
    real(8) :: oboc(3), oboa(3)
    real(8) :: ocoa(3), ocob(3)
    real(8) :: abab, acac
    real(8) :: bcbc, baba
    real(8) :: caca, cbcb

    real(8), parameter :: eps = 1.D-16
    real(8) :: pi
    !---------------------------------------------------------------------------

    pi = atan(1.D0) * 4.D0

    area = 0.D0

    if(trim(polygon_type)=='ON_PLANE') then
       !
       !---- Note : On a plane,
       !----        area = | ourter product of two vectors |.
       !
       call MISC_3dvec_cross( abc(:), a(:), b(:), a(:), c(:) )
       call MISC_3dvec_abs( prd, abc(:) )
       call MISC_3dvec_abs( r  , a(:)   )

       prd = 0.5D0 * prd !! triangle area
       if ( r < eps * radius ) then
          print *, "zero length?", a(:)
       else
          r = 1.D0 / r   !! 1 / length
       endif

       area = prd * r*r * radius*radius

    elseif(trim(polygon_type)=='ON_SPHERE') then
       !
       !---- NOTE : On a unit sphere,
       !----        area = sum of angles - pi.
       !

       ! angle 1
       call MISC_3dvec_cross( oaob(:), o(:), a(:), o(:), b(:) )
       call MISC_3dvec_cross( oaoc(:), o(:), a(:), o(:), c(:) )
       call MISC_3dvec_abs( abab, oaob(:) )
       call MISC_3dvec_abs( acac, oaoc(:) )

       if ( abab < eps * radius .OR. acac < eps * radius ) then
          write(*,'(A,3(E20.10))') "zero length abab or acac:", abab/radius, acac/radius
          return
       endif

       call MISC_3dvec_angle( angle(1), oaob(:), o(:), oaoc(:) )

       ! angle 2
       call MISC_3dvec_cross( oboc(:), o(:), b(:), o(:), c(:) )
       oboa(:) = -oaob(:)
       call MISC_3dvec_abs( bcbc, oboc(:) )
       baba = abab

       if ( bcbc < eps * radius .OR. baba < eps * radius ) then
          write(*,'(A,3(E20.10))') "zero length bcbc or baba:", bcbc/radius, baba/radius
          return
       endif

       call MISC_3dvec_angle( angle(2), oboc(:), o(:), oboa(:) )

       ! angle 3
       ocoa(:) = -oaoc(:)
       ocob(:) = -oboc(:)
       caca = acac
       cbcb = bcbc

       if ( caca < eps * radius .OR. cbcb < eps * radius ) then
          write(*,'(A,3(E20.10))') "zero length caca or cbcb:", caca/radius, cbcb/radius
          return
       endif

       call MISC_3dvec_angle( angle(3), ocoa(:), o(:), ocob(:) )

       ! calc area
       area = ( angle(1)+angle(2)+angle(3)-pi ) * radius*radius

    endif

    return
  end function MISC_3Dvec_triangle

  !-----------------------------------------------------------------------------
  subroutine MISC_3dvec_intersec( ifcross, p, a, b, c, d )
    ! judge intersection of two vector
    implicit none

    logical, intent(out) :: ifcross
    ! .true. : line a->b and c->d intersect
    ! .false.: line a->b and c->d do not intersect and p = (0,0)
    real(8), intent(out) :: p(3) ! intersection point
    real(8), intent(in ) :: a(3), b(3), c(3), d(3)

    real(8), parameter :: o(3) = 0.D0

    real(8)            :: oaob(3), ocod(3), cdab(3)
    real(8)            :: ip, length
    real(8)            :: angle_aop, angle_pob, angle_aob
    real(8)            :: angle_cop, angle_pod, angle_cod

    real(8), parameter :: eps = 1.D-12
    !---------------------------------------------------------------------

    call MISC_3dvec_cross( oaob, o, a, o, b )
    call MISC_3dvec_cross( ocod, o, c, o, d )
    call MISC_3dvec_cross( cdab, o, ocod, o, oaob )

    call MISC_3dvec_abs  ( length, cdab )
    call MISC_3dvec_dot  ( ip, o, cdab, o, a )

    p(:) = cdab(:) / sign(length,ip)
!    write(ADM_LOG_FID,*), "p:", p(:)

    call MISC_3dvec_angle( angle_aop, a, o, p )
    call MISC_3dvec_angle( angle_pob, p, o, b )
    call MISC_3dvec_angle( angle_aob, a, o, b )
!    write(ADM_LOG_FID,*), "angle a-p-b:", angle_aop, angle_pob, angle_aob

    call MISC_3dvec_angle( angle_cop, c, o, p )
    call MISC_3dvec_angle( angle_pod, p, o, d )
    call MISC_3dvec_angle( angle_cod, c, o, d )
!    write(ADM_LOG_FID,*), "angle c-p-d:", angle_cop, angle_pod, angle_cod

!    write(ADM_LOG_FID,*), "judge:", angle_aob-(angle_aop+angle_pob), angle_cod-(angle_cop+angle_pod)

    ! --- judge intersection
    if (       abs(angle_aob-(angle_aop+angle_pob)) < eps &
         .AND. abs(angle_cod-(angle_cop+angle_pod)) < eps &
         .AND. abs(angle_aop) > eps                       &
         .AND. abs(angle_pob) > eps                       &
         .AND. abs(angle_cop) > eps                       &
         .AND. abs(angle_pod) > eps                       ) then
       ifcross = .true.
    else
       ifcross = .false.
       p(:) = 0.D0
    endif

    return
  end subroutine MISC_3dvec_intersec

  !---------------------------------------------------------------------
  subroutine MISC_3dvec_anticlockwise( vertex, nvert )
    ! bubble sort anticlockwise by angle
    implicit none

    integer, intent(in)    :: nvert
    real(8), intent(inout) :: vertex(nvert,3)

    real(8), parameter :: o(3) = 0.D0
    real(8)            :: v1(3), v2(3), v3(3)
    real(8)            :: xp(3), ip
    real(8)            :: angle1, angle2

    real(8), parameter :: eps = 1.D-12

    integer :: i, j
    !---------------------------------------------------------------------

    do j = 2  , nvert-1
    do i = j+1, nvert
       v1(:) = vertex(1,:)
       v2(:) = vertex(j,:)
       v3(:) = vertex(i,:)

       call MISC_3dvec_cross( xp(:), v1(:), v2(:), v1(:), v3(:) )
       call MISC_3dvec_dot  ( ip, o(:), v1(:), o(:), xp(:) )

       if ( ip < -eps ) then ! right hand : exchange
!          write(ADM_LOG_FID,*) 'exchange by ip', i, '<->',j
          vertex(i,:) = v2(:)
          vertex(j,:) = v3(:)
       endif

    enddo
    enddo

    v1(:) = vertex(1,:)
    v2(:) = vertex(2,:)
    v3(:) = vertex(3,:)
    ! if 1->2->3 is on the line
    call MISC_3dvec_cross( xp(:), v1(:), v2(:), v1(:), v3(:) )
    call MISC_3dvec_dot  ( ip, o(:), v1(:), o(:), xp(:) )
    call MISC_3dvec_angle( angle1, v1(:), o, v2(:) )
    call MISC_3dvec_angle( angle2, v1(:), o, v3(:) )
!    write(ADM_LOG_FID,*) ip, angle1, angle2, abs(angle1)-abs(angle2)

    if (       abs(ip)                 < eps  &      ! on the same line
         .AND. abs(angle2)-abs(angle1) < 0.D0 ) then ! which is far?
!       write(ADM_LOG_FID,*) 'exchange by angle', 2, '<->', 3
       vertex(2,:) = v3(:)
       vertex(3,:) = v2(:)
    endif

    v2(:) = vertex(nvert  ,:)
    v3(:) = vertex(nvert-1,:)
    ! if 1->nvert->nvert-1 is on the line
    call MISC_3dvec_cross( xp(:), v1(:), v2(:), v1(:), v3(:) )
    call MISC_3dvec_dot  ( ip, o(:), v1(:), o(:), xp(:) )
    call MISC_3dvec_angle( angle1, v1(:), o, v2(:) )
    call MISC_3dvec_angle( angle2, v1(:), o, v3(:) )
!    write(ADM_LOG_FID,*) ip, angle1, angle2, abs(angle1)-abs(angle2)

    if (       abs(ip)                 < eps  &      ! on the same line
         .AND. abs(angle2)-abs(angle1) < 0.D0 ) then ! which is far?
!       write(ADM_LOG_FID,*) 'exchange by angle', nvert, '<->', nvert-1
       vertex(nvert,  :) = v3(:)
       vertex(nvert-1,:) = v2(:)
    endif

    return
  end subroutine MISC_3dvec_anticlockwise

  ![Add] H.Yashiro 11/06/01
  !-----------------------------------------------------------------------------
  subroutine MISC_get_cartesian( &
       x, y, z,  & !--- INOUT : Cartesian coordinate ( on the sphere )
       lat, lon, & !--- IN    : latitude and longitude, radian
       radius    ) !--- IN    : radius
    implicit none

    real(8),intent(inout) :: x, y, z
    real(8),intent(in)    :: lat, lon
    real(8),intent(in)    :: radius
    !---------------------------------------------------------------------------

    x = radius * cos(lat) * cos(lon)
    y = radius * cos(lat) * sin(lon) 
    z = radius * sin(lat)

    return
  end subroutine MISC_get_cartesian

  !-----------------------------------------------------------------------
  ! Get horizontal distance on the sphere
  !  2008/09/10 [Add] M.Hara
  !  The formuation is Vincentry (1975)
  !  http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf
  !  2012/11/07 [Mod] H.Yashiro
  subroutine MISC_get_distance( &
       r,    &
       lon1, &
       lat1, &
       lon2, &
       lat2, &
       dist  )
    implicit none

    real(8), intent(in)  :: r          ! radius in meter
    real(8), intent(in)  :: lon1, lat1 ! in radian
    real(8), intent(in)  :: lon2, lat2 ! in radian
    real(8), intent(out) :: dist       ! distance of the two points in meter

    real(8) :: gmm, gno_x, gno_y
    !-----------------------------------------------------------------------

    gmm = sin(lat1) * sin(lat2) &
        + cos(lat1) * cos(lat2) * cos(lon2-lon1)

    gno_x = gmm * ( cos(lat2) * sin(lon2-lon1) )
    gno_y = gmm * ( cos(lat1) * sin(lat2) &
                  - sin(lat1) * cos(lat2) * cos(lon2-lon1) )

    dist = r * atan2( sqrt(gno_x*gno_x+gno_y*gno_y), gmm )

    return
  end subroutine MISC_get_distance

  !-----------------------------------------------------------------------------
end module mod_misc
!-------------------------------------------------------------------------------


