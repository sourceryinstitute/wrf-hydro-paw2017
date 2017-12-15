program main  !! Test get_communicator language extension
  use opencoarrays, only : get_communicator
  use assertions_module, only : assert
  use iso_fortran_env, only : team_type
  use opencoarrays, only : get_communicator
  type(team_type) :: league
  integer, parameter :: num_teams=2 !! number of child teams to form
  implicit none
  call mpi_matches_caf(get_communicator()) !! verify rank & image numbering
  associate(initial_image=>this_image(), initial_num_images=>num_images(), destination_team=>mod(this_image()+1,num_teams)+1)
    form team(destination_team,league) !! create mapping
    change team(league) !! join child team
      call mpi_matches_caf(get_communicator()) !! verify new rank/image numbers
      associate(my_team=>team_number())
        call assert(my_team==destination_team,"assigned team matches chosen team")
        associate(new_num_images=>initial_num_images/num_teams+merge(1,0,my_team<=mod(initial_num_images,num_teams)))
         call assert(num_images()==new_num_images,"block distribution of images")
      end associate; end associate
    end team
    call assert( initial_image==this_image(),"correctly remapped to original image number")
    call assert( initial_num_images==num_images(),"correctly remapped to original number of images")
  end associate
  sync all; if (this_image()==1) print *,"Test passed."
contains
  subroutine mpi_matches_caf(comm) !! verify num. ranks =  num. images & image num. = rank num. + 1
    use iso_c_binding, only : c_int
    use mpi, only : MPI_COMM_SIZE, MPI_COMM_RANK
    integer(c_int), intent(in) :: comm  !! MPI communicator
    integer(c_int) :: isize,ierror,irank
    call MPI_COMM_SIZE(comm, isize, ierror)
    call assert( [ierror==0, isize==num_images()] ,"correct rank/image cardinality" )
    call MPI_COMM_RANK(comm, irank, ierror)
    call assert( [ierror==0, irank==this_image()-1,"correct rank/image numbering correspondence" )
  end subroutine
end program
