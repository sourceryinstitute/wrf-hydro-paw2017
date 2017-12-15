module assertions_module
  implicit none
contains
  elemental subroutine assert(assertion,description)
    logical, intent(in) :: assertion
    character(len=*), intent(in), optional :: description
    integer, parameter :: max_digits=12
    character(len=max_digits) :: image_number
    if (.not.assertion) then
      write(image_number,*) this_image()
      error stop "Assertion '" // description // "' failed on image " // trim(image_number)
    end if
  end subroutine
end module

program main  !! Test get_communicator language extension
  use opencoarrays, only : get_communicator
  use assertions_module, only : assert
  implicit none

  call mpi_matches_caf(get_communicator()) !! verify rank & image numbering
  block
    use iso_fortran_env, only : team_type
    use opencoarrays, only : get_communicator
    type(team_type) :: league
    integer, parameter :: num_teams=2 !! number of child teams to form

    associate(initial_image=>this_image(), initial_num_images=>num_images(), chosen_team=>destination_team(this_image(),num_teams))
      form team(chosen_team,league) !! create mapping
      change team(league) !! join child team
        call mpi_matches_caf(get_communicator()) !! verify new rank/image numbers
        associate(my_team=>team_number())
          call assert(my_team==chosen_team,"assigned team matches chosen team")
          associate(new_num_images=>initial_num_images/num_teams+merge(1,0,my_team<=mod(initial_num_images,num_teams)))
           call assert(num_images()==new_num_images,"block distribution of images")
          end associate
        end associate
      end team
      call assert( initial_image==this_image(),"correctly remapped to original image number")
      call assert( initial_num_images==num_images(),"correctly remapped to original number of images")
    end associate
  end block
  sync all
  if (this_image()==1) print *,"Test passed."
contains
   pure function destination_team(image,numTeams) result(team)
     integer, intent(in) ::image, numTeams
     integer ::team
     team = mod(image+1,numTeams)+1
   end function

  subroutine mpi_matches_caf(comm)
    !! verify new # ranks = new # images & new image number = new rank + 1
    use iso_c_binding, only : c_int
    use mpi, only : MPI_COMM_SIZE, MPI_COMM_RANK
    integer(c_int), intent(in) :: comm
      !! MPI communicator
    integer(c_int) :: isize,ierror,irank
    call MPI_COMM_SIZE(comm, isize, ierror)
    call assert( ierror==0 , "'call MPI_COMM_SIZE' successful" )
    call assert( isize==num_images(), "num MPI ranks = num CAF images " )
    call MPI_COMM_RANK(comm, irank, ierror)
    call assert( ierror==0 , "'call MPI_COMM_RANK' successful" )
    call assert( irank==this_image()-1 , "correct rank/image correspondence" )
  end subroutine
end program
