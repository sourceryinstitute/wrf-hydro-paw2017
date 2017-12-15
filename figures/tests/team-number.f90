program main
 !! Test team_number intrinsic function
 use iso_fortran_env, only : team_type
 use assertions_module, only : assertions
 implicit none
 integer, parameter :: standard_initial_value=-1
 type(team_type), target :: home
 call assert(team_number()==standard_initial_value)
 associate(my_team=>mod(this_image(),2)+1)
  form team(my_team,home)
    !! Map image numbers: my_team=1 for even, 2 for odd
  change team(home)
    call assert(team_number()==my_team,"correct mapping")
  end team
  call assert(team_number()==standard_initial_value)
 end associate
 sync all
 if (this_image()==1) print *,"Test passed."
end program
