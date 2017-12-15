program main
  !! Test team_number intrinsic function
  use iso_fortran_env, only : team_type
  use assertions_module, only : assertions
  implicit none

  integer, parameter :: standard_value=-1
  type(team_type), target :: home

  call assert(team_number()==standard_value,"correct value before first 'change team'")

  associate(my_team=>mod(this_image(),2)+1)
    form team(my_team,home)
      !! Create two-team mapping:
      !! my_team=1 for even image numbers in the initial team; 2 for odd image numbers
    change team(home)
      call assert(team_number()==my_team,"correct team number mapping after 'change team'")
    end team
    call assert(team_number()==standard_initial_value,"returned to the initial team")
  end associate

  sync all
  if (this_image()==1) print *,"Test passed."
end program
