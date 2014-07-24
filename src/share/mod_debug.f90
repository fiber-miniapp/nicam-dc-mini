!-------------------------------------------------------------------------------
!>
!! Debug utility module
!!
!! @par Description
!!         This module is for dubug.
!!
!! @author  H.Tomita
!!
!! @par History
!! @li      2012-06-29 (H.Yashiro)  [NEW]
!<
module mod_debug
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
  public :: DEBUG_dampdata
  public :: DEBUG_dampascii4D
  public :: DEBUG_dampascii3D
  public :: DEBUG_rapstart
  public :: DEBUG_rapend
  public :: DEBUG_rapreport

  !-----------------------------------------------------------------------------
  !
  !++ Public parameters & variables
  !
  !-----------------------------------------------------------------------------
  !
  !++ Private procedure
  !
  private :: DEBUG_rapid

  !-----------------------------------------------------------------------------
  !
  !++ Private parameters & variables
  !
  integer,                 private, parameter :: DEBUG_rapnlimit = 100
  integer,                 private,      save :: DEBUG_rapnmax   = 0
  character(len=ADM_NSYS), private,      save :: DEBUG_rapname(DEBUG_rapnlimit)
  real(8),                 private,      save :: DEBUG_raptstr(DEBUG_rapnlimit)
  real(8),                 private,      save :: DEBUG_rapttot(DEBUG_rapnlimit)
  integer,                 private,      save :: DEBUG_rapnstr(DEBUG_rapnlimit)
  integer,                 private,      save :: DEBUG_rapnend(DEBUG_rapnlimit)

#ifdef PAPI_OPS
  ! <-- [add] PAPI R.Yoshida 20121022
  !integer(8),public, save :: papi_flpins    !total floating point instructions since the first call
  integer(8),public, save :: papi_flpops    !total floating point operations since the first call
  !real(4),   public, save :: papi_real_time_i !total realtime since the first PAPI_flins() call 
  !real(4),   public, save :: papi_proc_time_i !total process time since the first PAPI_flins() call 
  real(4),   public, save :: papi_real_time_o !total realtime since the first PAPI_flops() call 
  real(4),   public, save :: papi_proc_time_o !total process time since the first PAPI_flops() call 
  !real(4),   public, save :: papi_mflins    !Mflip/s achieved since the previous call 
  real(4),   public, save :: papi_mflops    !Mflop/s achieved since the previous call 
  integer,   public, save :: papi_check
#endif

  !-----------------------------------------------------------------------------
contains

  !-----------------------------------------------------------------------------
  !>
  !> Damp all data
  !>
  subroutine DEBUG_dampdata( &
      basename, & !--- [IN]
      var,      & !--- [IN]
      var_pl    ) !--- [IN]
    use mod_misc, only: &
       MISC_make_idstr, &
       MISC_get_available_fid
    use mod_adm, only: &
         ADM_PRC_PL, &
         ADM_prc_me
    implicit none

    character(len=*), intent(in) :: basename
    real(8),          intent(in) :: var   (:,:,:,:)
    real(8),          intent(in) :: var_pl(:,:,:,:)

    integer :: shp(4)

    character(LEN=ADM_MAXFNAME) :: fname

    integer :: fid
    !---------------------------------------------------------------------------

    shp(:) = shape(var)

    call MISC_make_idstr(fname,trim(basename),'pe',ADM_prc_me)
    fid = MISC_get_available_fid()
    open( unit   = fid,                           &
          file   = trim(fname),                   &
          form   = 'unformatted',                 &
          access = 'direct',                      &
          recl   = shp(1)*shp(2)*shp(3)*shp(4)*8, &
          status = 'unknown'                      )

       write(fid,rec=1) var

    close(fid)

    if ( ADM_prc_me == ADM_prc_pl ) then
       shp(:) = shape(var_pl)

       fname = trim(basename)//'.pl'
       fid = MISC_get_available_fid()
       open( unit   = fid,                           &
             file   = trim(fname),                   &
             form   = 'unformatted',                 &
             access = 'direct',                      &
             recl   = shp(1)*shp(2)*shp(3)*shp(4)*8, &
             status = 'unknown'                      )

          write(fid,rec=1) var_pl

       close(fid)

    endif

  end subroutine DEBUG_dampdata

  !-----------------------------------------------------------------------------
  !>
  !> Damp all data
  !>
  subroutine DEBUG_dampascii4D( &
      basename, & !--- [IN]
      var,      & !--- [IN]
      var_pl    ) !--- [IN]
    use mod_misc, only: &
       MISC_make_idstr, &
       MISC_get_available_fid
    use mod_adm, only: &
       ADM_prc_pl, &
       ADM_prc_me
    implicit none

    character(len=*), intent(in) :: basename
    real(8),          intent(in) :: var   (:,:,:,:)
    real(8),          intent(in) :: var_pl(:,:,:,:)

    integer :: shp(4)

    character(LEN=ADM_MAXFNAME) :: fname

    integer :: fid
    integer :: i1,i2,i3,i4
    !---------------------------------------------------------------------------

    shp(:) = shape(var)

    call MISC_make_idstr(fname,trim(basename),'txt',ADM_prc_me)
    fid = MISC_get_available_fid()
    open( unit   = fid,         &
          file   = trim(fname), &
          form   = 'formatted', &
          status = 'unknown'    )

       do i4 = 1, shp(4)
       do i3 = 1, shp(3)
       do i2 = 1, shp(2)
       do i1 = 1, shp(1)
          write(fid,*) "(",i1,",",i2,",",i3,",",i4,")=",var(i1,i2,i3,i4)
       enddo
       enddo
       enddo
       enddo

    close(fid)

    if ( ADM_prc_me == ADM_prc_pl ) then
       shp(:) = shape(var_pl)

       fname = trim(basename)//'.txtpl'
       fid = MISC_get_available_fid()
       open( unit   = fid,         &
             file   = trim(fname), &
             form   = 'formatted', &
             status = 'unknown'    )

          do i4 = 1, shp(4)
          do i3 = 1, shp(3)
          do i2 = 1, shp(2)
          do i1 = 1, shp(1)
             write(fid,*) "(",i1,",",i2,",",i3,",",i4,")=",var_pl(i1,i2,i3,i4)
          enddo
          enddo
          enddo
          enddo

       close(fid)

    endif

  end subroutine DEBUG_dampascii4D

  !-----------------------------------------------------------------------------
  !>
  !> Damp all data
  !>
  subroutine DEBUG_dampascii3D( &
      basename, & !--- [IN]
      var,      & !--- [IN]
      var_pl    ) !--- [IN]
    use mod_misc, only: &
       MISC_make_idstr, &
       MISC_get_available_fid
    use mod_adm, only: &
       ADM_prc_pl, &
       ADM_prc_me
    implicit none

    character(len=*), intent(in) :: basename
    real(8),          intent(in) :: var   (:,:,:)
    real(8),          intent(in) :: var_pl(:,:,:)

    integer :: shp(3)

    character(LEN=ADM_MAXFNAME) :: fname

    integer :: fid
    integer :: i1,i2,i3
    !---------------------------------------------------------------------------

    shp(:) = shape(var)

    call MISC_make_idstr(fname,trim(basename),'txt',ADM_prc_me)
    fid = MISC_get_available_fid()
    open( unit   = fid,         &
          file   = trim(fname), &
          form   = 'formatted', &
          status = 'unknown'    )

       do i3 = 1, shp(3)
       do i2 = 1, shp(2)
       do i1 = 1, shp(1)
          write(fid,*) "(",i1,",",i2,",",i3,")=",var(i1,i2,i3)
       enddo
       enddo
       enddo

    close(fid)

    if ( ADM_prc_me == ADM_prc_pl ) then
       shp(:) = shape(var_pl)

       fname = trim(basename)//'.txtpl'
       fid = MISC_get_available_fid()
       open( unit   = fid,         &
             file   = trim(fname), &
             form   = 'formatted', &
             status = 'unknown'    )

          do i3 = 1, shp(3)
          do i2 = 1, shp(2)
          do i1 = 1, shp(1)
             write(fid,*) "(",i1,",",i2,",",i3,")=",var_pl(i1,i2,i3)
          enddo
          enddo
          enddo

       close(fid)

    endif

  end subroutine DEBUG_dampascii3D

  !-----------------------------------------------------------------------------
  function DEBUG_rapid( rapname ) result(id)
    implicit none

    character(len=*), intent(in) :: rapname

    integer :: id
    !---------------------------------------------------------------------------

    if ( DEBUG_rapnmax >= 1 ) then
       do id = 1, DEBUG_rapnmax
          if( trim(rapname) == trim(DEBUG_rapname(id)) ) return
       enddo
    endif

    DEBUG_rapnmax     = DEBUG_rapnmax + 1
    id                = DEBUG_rapnmax
    DEBUG_rapname(id) = trim(rapname)
    DEBUG_raptstr(id) = 0.D0
    DEBUG_rapttot(id) = 0.D0
    DEBUG_rapnstr(id) = 0
    DEBUG_rapnend(id) = 0

  end function DEBUG_rapid

  !-----------------------------------------------------------------------------
  subroutine DEBUG_rapstart( rapname )
    implicit none

    character(len=*), intent(in) :: rapname

    real(8) :: time

    integer :: id
    !---------------------------------------------------------------------------

    id = DEBUG_rapid( rapname )

    time = real(MPI_WTIME(), kind=8)

    DEBUG_raptstr(id) = time
    DEBUG_rapnstr(id) = DEBUG_rapnstr(id) + 1

#ifdef _FAPP_
call START_COLLECTION( rapname )
#endif

    return
  end subroutine DEBUG_rapstart

  !-----------------------------------------------------------------------------
  subroutine DEBUG_rapend( rapname )
    implicit none

    character(len=*), intent(in) :: rapname

    real(8) :: time

    integer :: id
    !---------------------------------------------------------------------------

    id = DEBUG_rapid( rapname )

    time = real(MPI_WTIME(), kind=8)

    DEBUG_rapttot(id) = DEBUG_rapttot(id) + ( time-DEBUG_raptstr(id) )
    DEBUG_rapnend(id) = DEBUG_rapnend(id) + 1

#ifdef _FAPP_
call STOP_COLLECTION( rapname )
#endif

    return
  end subroutine DEBUG_rapend

  !-----------------------------------------------------------------------------
  subroutine DEBUG_rapreport
    use mod_adm, only: &
       ADM_COMM_RUN_WORLD, &
       ADM_prc_all,        &
       ADM_prc_me
    implicit none

    real(8) :: sendbuf(1)
    real(8) :: recvbuf(ADM_prc_all)

    real(8) :: globalavg, globalmax, globalmin
#ifdef PAPI_OPS
    real(8) :: globalsum, total_flops
#endif

    integer :: ierr
    integer :: id
    !---------------------------------------------------------------------------

    if ( DEBUG_rapnmax >= 1 ) then

       do id = 1, DEBUG_rapnmax
          if ( DEBUG_rapnstr(id) /= DEBUG_rapnend(id) ) then
              write(*,*) '*** Mismatch Report',id,DEBUG_rapname(id),DEBUG_rapnstr(id),DEBUG_rapnend(id)
          endif
       enddo

       write(ADM_LOG_FID,*)
       write(ADM_LOG_FID,*) '*** Computational Time Report'

!       do id = 1, DEBUG_rapnmax
!          write(ADM_LOG_FID,'(1x,A,I3.3,A,A,A,F10.3,A,I7)') &
!          '*** ID=',id,' : ',DEBUG_rapname(id),' T=',DEBUG_rapttot(id),' N=',DEBUG_rapnstr(id)
!       enddo

       do id = 1, DEBUG_rapnmax
          sendbuf(1) = DEBUG_rapttot(id)
          call MPI_Allgather( sendbuf,              &
                              1,                    &
                              MPI_DOUBLE_PRECISION, &
                              recvbuf,              &
                              1,                    &
                              MPI_DOUBLE_PRECISION, &
                              ADM_COMM_RUN_WORLD,   &
                              ierr                  )

          globalavg = sum( recvbuf(:) ) / real(ADM_prc_all,kind=8)
          globalmax = maxval( recvbuf(:) )
          globalmin = minval( recvbuf(:) )

          write(ADM_LOG_FID,'(1x,A,I3.3,A,A,A,F10.3,A,F10.3,A,F10.3,A,I7)') &
                            '*** ID=',   id,                &
                            ' : ',       DEBUG_rapname(id), &
                            '  T(avg)=', globalavg,         &
                            ', T(max)=', globalmax,         &
                            ', T(min)=', globalmin,         &
                            ', N=',      DEBUG_rapnstr(id)
       enddo
    else
       write(ADM_LOG_FID,*)
       write(ADM_LOG_FID,*) '*** Computational Time Report: NO item.'
    endif

#ifdef PAPI_OPS
    ! [add] PAPI R.Yoshida 20121022
    !write(ADM_LOG_FID,*) ' *** Type: Instructions'
    !write(ADM_LOG_FID,*) ' --- Real Time:',papi_real_time_i*2.0d0,' Proc. Time:',papi_proc_time_i*2.0d0
    !write(ADM_LOG_FID,*) ' --- flop inst:',papi_flpins*2,'  Gflins/s:',papi_mflins*2.0d0/1.0d3  !GIGA
    write(ADM_LOG_FID,*)
    write(ADM_LOG_FID,*) '********* PAPI report *********'
    write(ADM_LOG_FID,*) '*** Type: Operations'
    write(ADM_LOG_FID,*) '--- Wall clock Time      [sec] (this PE):', papi_real_time_o
    write(ADM_LOG_FID,*) '--- Processor Time       [sec] (this PE):', papi_proc_time_o
    write(ADM_LOG_FID,*) '--- Floating Operations [FLOP] (this PE):', papi_flpops
    write(ADM_LOG_FID,*) '--- FLOPS by PAPI     [MFLOPS] (this PE):', papi_mflops
    write(ADM_LOG_FID,*) '--- FLOP / Time       [MFLOPS] (this PE):', papi_flpops / papi_proc_time_o / 1024.D0**2 !GIGA
    write(ADM_LOG_FID,*)

    sendbuf(1) = real(papi_proc_time_o,kind=8)
    call MPI_Allgather( sendbuf,              &
                        1,                    &
                        MPI_DOUBLE_PRECISION, &
                        recvbuf,              &
                        1,                    &
                        MPI_DOUBLE_PRECISION, &
                        ADM_COMM_RUN_WORLD,   &
                        ierr                  )

    globalavg = sum( recvbuf(:) ) / real(ADM_prc_all,kind=8)
    globalmax = maxval( recvbuf(:) )
    globalmin = minval( recvbuf(:) )

    call COMM_Stat_avg( real(papi_proc_time_o,kind=8), globalavg )
    call COMM_Stat_max( real(papi_proc_time_o,kind=8), globalmax )
    call COMM_Stat_min( real(papi_proc_time_o,kind=8), globalmin )

    write(ADM_LOG_FID,'(1x,A,F10.3,A,F10.3,A,F10.3)') &
                      '--- Processor Time        [sec] (avg)=', globalavg, &
                                                    ', (max)=', globalmax, &
                                                    ', (min)=', globalmin

    sendbuf(1) = real(papi_flpops,kind=8)
    call MPI_Allgather( sendbuf,              &
                        1,                    &
                        MPI_DOUBLE_PRECISION, &
                        recvbuf,              &
                        1,                    &
                        MPI_DOUBLE_PRECISION, &
                        ADM_COMM_RUN_WORLD,   &
                        ierr                  )

    globalsum = sum( recvbuf(:) )
    globalavg = globalsum / real(ADM_prc_all,kind=8)
    globalmax = maxval( recvbuf(:) )
    globalmin = minval( recvbuf(:) )

    total_flops = globalsum / globalmax / 1024.D0**3

    write(ADM_LOG_FID,'(1x,A,F10.3,A,F10.3,A,F10.3)') &
                      '--- Floating Operations [GFLOP] (avg)=', globalavg / 1024.D0**3, &
                                                    ', (max)=', globalmax / 1024.D0**3, &
                                                    ', (min)=', globalmin / 1024.D0**3
    write(ADM_LOG_FID,'(1x,A,F10.3)') &
                      '--- Total Flops [GFLOPS] (all PE):',total_flops

    call PAPIF_shutdown
#endif

    return
  end subroutine DEBUG_rapreport

end module mod_debug
