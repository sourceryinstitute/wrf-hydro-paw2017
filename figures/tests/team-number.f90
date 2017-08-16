program main
  !! summary: Test team_number intrinsic function
  use iso_fortran_env, only : team_type
  use iso_c_binding, only : c_loc
  use opencoarrays, only : team_number
  use assertions_module, only : assertions
    !! TODO: remove the above line below after the compiler supports team_number
  implicit none

  integer, parameter :: standard_initial_value=-1
  type(team_type), target :: home

  call assert(team_number()==standard_initial_value,"initial team number conforms with Fortran standard before 'change team'")

  after_change_team: block
    associate(my_team=>mod(this_image(),2)+1)
      !! Prepare for forming two teams: my_team = 1 for even image numbers in the initial team; 2 for odd image numbers
      form team(my_team,home)
      change team(home)
        call assert(team_number()==my_team,"team number conforms with Fortran standard after 'change team'")
      end team
      call assert(team_number()==standard_initial_value,"initial team number conforms with Fortran standard")
    end associate
  end block after_change_team

  sync all
  if (this_image()==1) print *,"Test passed."

end program
