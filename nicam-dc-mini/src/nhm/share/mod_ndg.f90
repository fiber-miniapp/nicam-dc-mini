!cx Warning
!cx Nudging function is removed in this mini-version
!cx This file is provided only for printing error messages
module mod_ndg
  implicit none
  public :: ndg_setup
contains
  subroutine ndg_setup(ctime, dtime)
    implicit none
    real(8), intent(in) :: ctime
    real(8), intent(in) :: dtime
write(*,*) "*** Error. Nudging function was removed in mini-version."
stop
    return
  end subroutine ndg_setup
end module mod_ndg

