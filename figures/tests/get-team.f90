program main
  !! summary: Test get_team function, an OpenCoarrays-specific language extension
  use opencoarrays, only : get_team

  implicit none

  call mpi_matches_caf(get_team())
    !! verify # ranks = # images and image number = rank + 1

  block
    use iso_fortran_env, only : team_type
    use opencoarrays, only : get_team, team_number !! TODO: remove team_number once gfortran supports it

    type(team_type) :: league
    integer, parameter :: num_teams=2
      !! number of child teams to form from the parent initial team

    associate(initial_image=>this_image(), initial_num_images=>num_images(), chosen_team=>destination_team(this_image(),num_teams))

      form team(chosen_team,league)
        !! map images to num_teams teams

      change team(league)
        !! join my destination team

        call mpi_matches_caf(get_team())
          !! verify new # ranks = new # images and new image number = new rank + 1

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
    use iso_c_binding, only : c_int
    use mpi, only : MPI_COMM_SIZE, MPI_COMM_RANK
    integer(c_int), intent(in) :: comm
      !! MPI communicator
    integer(c_int) :: isize,ierror,irank

    call MPI_COMM_SIZE(comm, isize, ierror)
    call assert( ierror==0 , "successful call MPI_COMM_SIZE" )
    call assert( isize==num_images(), "num MPI ranks = num CAF images " )

    call MPI_COMM_RANK(comm, irank, ierror)
    call assert( ierror==0 , "successful call MPI_COMM_RANK" )
    call assert( irank==this_image()-1 , "correct rank/image-number correspondence" )

  end subroutine

  elemental subroutine assert(assertion,description)
    !! TODO: move this to a common place for all tests to use
    logical, intent(in) :: assertion
    character(len=*), intent(in) :: description
    integer, parameter :: max_digits=12
    character(len=max_digits) :: image_number
    if (.not.assertion) then
      write(image_number,*) this_image()
      error stop "Assertion '" // description // "' failed on image " // trim(image_number)
    end if
  end subroutine

end program
