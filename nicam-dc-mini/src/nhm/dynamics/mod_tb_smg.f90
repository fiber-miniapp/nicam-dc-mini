! To do list
!
! - change Gamma (parameter) --> (variable)
! - change Pr(parameter) --> (variable)
! - Effect of stratos
! - Energy_tot ok?
! - potem_l    ok?
! 
!-------------------------------------------------------------------------------
!
!+  Smagorinsky turbulent diffusion module
!
!-------------------------------------------------------------------------------
module mod_tb_smg
  !-----------------------------------------------------------------------------
  !
  !++ Description: 
  !       This module contains subroutines for Smagorinsky-type turbulent diffusion
  !       
  ! 
  !++ Current Corresponding Authors : S.Iga and A.Noda
  ! 
  !++ History: 
  !      Version   Date       Comment 
  !      -----------------------------------------------------------------------
  !      0.00      11-xx-xx   generated
  !                10-12-03   Iga modified
  !                10-12-27   Iga modified
  !                11-11-28   Y.Yamada: Merge Terai-san code into
  !                                                         the original code.
  !      -----------------------------------------------------------------------
  !
  !-----------------------------------------------------------------------------
  !
  !++ Used modules
  !
  use mod_adm, only :  &
       ADM_log_fid, &
       ADM_prc_me, &
       ADM_prc_pl, &
       ADM_gall, &
       ADM_kall, &
       ADM_lall, &
       ADM_gall_pl, &
       ADM_lall_pl, &
       ADM_knone,        &
       ADM_kmin,         &
       ADM_kmax, &
       ADM_NSYS
    use mod_vmtr,only:&
         VMTR_GSGAM2,&
         VMTR_RGAM2,&
         VMTR_RGAM2H,&
         VMTR_RGSGAM2,&
         VMTR_RGSGAM2H,&
         VMTR_GAM2,&
         VMTR_GAM2H,&
         VMTR_GSGAM2H,   &
         VMTR_GZX,&
         VMTR_GZXH,&
         VMTR_GZY,&
         VMTR_GZZ,&
         VMTR_GZYH,&
         VMTR_GZZH,&
         VMTR_RGSH,&
         VMTR_RGAM,&
         VMTR_GAM2_PL,&
         VMTR_GAM2H_PL,&
         VMTR_GSGAM2H_pl,&
         VMTR_GSGAM2_PL,&
         VMTR_RGAM2_PL,&
         VMTR_RGAM2H_PL,&
         VMTR_RGSGAM2_PL,&
         VMTR_RGSGAM2H_PL,&
         VMTR_GZX_PL,&
         VMTR_GZY_PL,&
         VMTR_GZXH_PL,&
         VMTR_GZYH_PL,&
         VMTR_GZZ_PL,&
         VMTR_GZZH_PL,&
         VMTR_RGSH_PL,&
         VMTR_RGAM_PL
    use mod_history
  !-----------------------------------------------------------------------------
!cx
!cx Deleted the procedure blocks
!cx Deleted the private variables
!cx

end module mod_tb_smg
!-------------------------------------------------------------------------------
