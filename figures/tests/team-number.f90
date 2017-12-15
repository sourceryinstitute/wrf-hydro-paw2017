module assertions_module!Terminate globally if test fails
 implicit none
contains
 elemental subroutine assert(assertion,description)
   logical, intent(in) :: assertion
   character(len=*), intent(in), optional :: description
   integer, parameter :: max_digits=12
   character(len=max_digits) :: image_number
   if (.not.assertion) then
    write(image_number,*) this_image()
    error stop description//" failed on image "//image_number
   end if
 end subroutine
end module

program main !! Test team_number intrinsic function
 use iso_fortran_env, only : team_type
 use assertions_module, only : assertions
 implicit none
 integer, parameter :: standard_initial_value=-1
 type(team_type), target :: home
 call assert(team_number()==standard_initial_value)
 associate(my_team=>mod(this_image(),2)+1)
  form team(my_team,home)!Map even|odd images->teams 1|2
  change team(home)
    call assert(team_number()==my_team,"correct mapping")
  end team
  call assert(team_number()==standard_initial_value)
 end associate
 sync all; if (this_image()==1) print *,"Test passed."
end program
