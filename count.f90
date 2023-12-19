program count
  integer :: i, target
  character(len=10) :: arg

  call getarg(1, arg)
  read(arg,*) target

  i = 0
  do while (i < target)
    i = i + 1;
  end do

  print *, i
end program count
