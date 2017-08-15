program main
  !! summary: Test team_number intrinsic function
  use iso_fortran_env, only : team_type
  use iso_c_binding, only : c_loc

  use opencoarrays, only : team_number
    !! TODO: remove the above line below after the compiler supports team_number

  implicit none

  integer, parameter :: standard_initial_value=-1

  type(team_type), target :: home

  call assert(team_number()==standard_initial_value,"initial team number conforms with Fortran standard before 'change team'")

 !call assert(
 !  team_number(c_loc(home))==standard_initial_value,"initial team number conforms with Fortran standard before 'change team'"
 !)
   !! TODO: uncomment the above assertion after implementing support for team_number's optional argument:

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

contains

  elemental subroutine assert(assertion,description)
    !! TODO: move this to a common place for all tests to use
    logical, intent(in) :: assertion
    character(len=*), intent(in) :: description
    integer, parameter :: max_digits=12
    character(len=max_digits) :: image_number
    if (.not.assertion) then
      write(image_number,*) this_image()
      error stop "Assertion " // description // "failed on image " // trim(image_number)
    end if
  end subroutine

end program
