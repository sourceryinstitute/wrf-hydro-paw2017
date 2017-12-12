program main
  !! Test team_number intrinsic function
  use iso_fortran_env, only : team_type
  use opencoarrays, only : team_number
  use assertions_module, only : assertions
  implicit none

  integer, parameter :: standard_initial_value=-1
  type(team_type), target :: home

  call assert(team_number()==standard_initial_value,"initial team number conforms with Fortran standard before 'change team'")

  associate(my_team=>mod(this_image(),2)+1)
    form team(my_team,home)
      !! Create two-team mapping: my_team=1 for even image numbers in the initial team; 2 for odd image numbers
    change team(home)
      call assert(team_number()==my_team,"team number maps to desired team after 'change team'")
    end team
    call assert(team_number()==standard_initial_value,"returned to the initial team")
  end associate

  sync all
  if (this_image()==1) print *,"Test passed."

end program
